require_relative '../src/semaphore/semaphore'

describe 'test semaphore core' do

  before do
    @semaphore = Semaphore.new 3
  end

  it 'test initialization with invalid input' do
    expect { Semaphore.new(-3) }.to raise_error(SemaphoreException)
  end

  it 'test initialization with known input' do
    semaphore = Semaphore.new 2
    expect(semaphore.count).to eq 0
    expect(semaphore.max).to eq 2
  end

  it 'test increment' do

    expect(@semaphore.dwait).to receive(:signal)
    expect(@semaphore.mon).to receive(:synchronize).and_yield

    @semaphore.increment
    sleep(2)
    expect(@semaphore.count).to eq(1)
  end

  it 'test decrement' do

    2.times do
      @semaphore.increment
    end
    expect(@semaphore.count).to eq(2)

    expect(@semaphore.mon).to receive(:synchronize).exactly(4).times.and_yield
    expect(@semaphore).to receive(:count_sync)

    @semaphore.decrement
    expect(@semaphore.count).to eq(1)

    @semaphore.increment

    @semaphore.decrement 2
    expect(@semaphore.count).to eq(0)

  end

  it 'test syncronize' do

    @semaphore.synchronize do
      expect(@semaphore.count).to eq(1)
      sleep(0.5)
    end
    expect(@semaphore.count).to eq(0)
  end

  it 'test syncronize callbacks' do

    expect(@semaphore).to receive(:increment)
    expect(@semaphore).to receive(:decrement)
    @semaphore.synchronize do
      sleep(0.5)
    end
  end

end
