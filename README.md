[![Stories in Ready](https://badge.waffle.io/frp-utn/ruby-concurrent-patterns.png?label=ready&title=Ready)](https://waffle.io/frp-utn/ruby-concurrent-patterns)
Ruby Concurrent Patterns
==========

[![Build Status](https://travis-ci.org/frp-utn/ruby-concurrent-patterns.svg)](https://travis-ci.org/frp-utn/ruby-concurrent-patterns)
[![Code Climate](https://codeclimate.com/github/frp-utn/ruby-concurrent-patterns/badges/gpa.svg)](https://codeclimate.com/github/frp-utn/ruby-concurrent-patterns)
[![Test Coverage](https://codeclimate.com/github/frp-utn/ruby-concurrent-patterns/badges/coverage.svg)](https://codeclimate.com/github/frp-utn/ruby-concurrent-patterns)

## Objective

The objective of this repository is to show the most common concurrent algorithms for concurrency in Ruby, using the Ruby interpreter. Then implement these patterns or other ones on JRuby and make conclussions on results.

## Problems in Ruby Interpreter

![Alt text](https://raw.githubusercontent.com/frp-utn/ruby-concurrent-patterns/master/xruby-gil-jvm.png)

Ruby can inplement concurrency but not parallelism due to the global interpreter lock, which is a mutual exclusion lock. This lock is held by the interpreter thread and uses it to prevent sharing code that's not thread safe with other threads. All the interpreter threads have their own GIL. 
Due to this GIL, if a Ruby program has different threads, they can't run at the same time, because GIL will only allow one thread to run at the same time. Before Ruby 1.9, there was only one operating system thread also. After Ruby 1.9, we can have multiple OS threads so we can now use more than one processor core. There's still a drawback that is, we'll still use one thread at a time and again not taking advantage of the multicore architecture. 

On Java you can define multiple threads, the difference is that on the JVM, it can map each JVM thread to a OS one, this will take advantage of the multicore architecture.

## Patterns

This repo will have initially Ruby implementations of concurrent patterns, and then similar implementations on JRuby.

Some of the patterns/techniques will be:

- Threads
- Fibers
- Reactor
- DataFlow
- Mutex/Semaphores
- IPC



