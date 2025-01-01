require 'babs'

describe 'babs' do
  def test_single_task(&block)
    x = test_multi_task do
      task('test task', &block)

      root_task 'test task'
    end
  end

  def test_multi_task(&block)
    x = Class.new(Babs, &block).new(logger: StringIO.new(""))
  end

  it 'does not run meet block when met?' do
    x = test_single_task do
      met? { @run = true }
      meet { raise }
    end

    x.apply
  end

  it 'run meets block when not met' do
    x = test_single_task do
      met? { @done }
      meet { @done = true }
    end

    x.apply
  end

  it 'fails if not met? after meeting' do
    x = test_single_task do
      met? { false }
      meet { }
    end

    expect {
      x.apply
    }.to raise_error(/task not met/)
  end

  it 'runs dependent task first' do
    x = test_multi_task do
      task 'dependency' do
        met? { true }
      end

      task 'goal', depends: 'dependency' do
        met? { true }
      end

      root_task 'goal'
    end

    expect(x.apply).to eq(%w(dependency goal))
  end

  it 'only ever runs tasks once' do
    x = test_multi_task do
      task 'dependency' do
        met? {
          store_variable 'x', read_variable('x') + 1
          true
        }
      end

      task 'goal a', depends: 'dependency' do
        met? { true }
      end

      task 'goal b', depends: 'dependency' do
        met? { true }
      end

      task 'goal c', depends: ['goal a', 'goal b'] do
        met? { read_variable('x') == 1 }
        meet { raise }
      end

      variables 'x' => 0

      root_task ['goal c']
    end

    x.apply
  end

  it 'allows variables' do
    x = test_multi_task do
      task 'goal' do
        met? { read_variable('x') == 2 }
        meet { store_variable 'x', read_variable('y') }
      end

      variables \
        'x' => 0,
        'y' => 2

      root_task 'goal'
    end

    x.apply
  end

  it 'allows defered variables' do
    x = test_multi_task do
      task 'goal' do
        met? { read_variable('x') == 2 }
        meet { store_variable 'x', read_variable('y') }
      end

      variables \
        'x' => 0,
        'y' => ->{ 2 }

      root_task 'goal'
    end

    x.apply
  end

  it 'does not read defered variables until used' do
    x = test_multi_task do
      task 'goal' do
        met? { read_variable('x') == 0 }
      end

      variables \
        'x' => 0,
        'y' => ->{ raise }

      root_task 'goal'
    end

    x.apply
  end
end
