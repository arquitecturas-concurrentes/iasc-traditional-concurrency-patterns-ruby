require_relative '../src/reactor'

describe 'test reactor core' do

  before do
    @reactor = Reactor::Dispatcher.new
  end

  it 'test write some content with a write event' do
    buffer = ''
    @reactor.attach_handler(:write,STDOUT)  do
      buffer << 'Hola Mundo!'
    end
    @reactor.run_cycle
    expect(buffer).to eq('Hola Mundo!')
  end




end
