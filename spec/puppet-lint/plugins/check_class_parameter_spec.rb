require 'spec_helper'

describe 'class_parameter' do
  context 'with fix disabled' do
    context 'class with no parameters' do
      let(:code) { <<-EOF
        class puppet_module() { }
        EOF
      }

      it 'has no problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'class with only required parameters' do
      context 'sorted alphabetically' do
        let(:code) { <<-EOF
          class puppet_module(
            String $alphabetical,
            String $non_alphabetical
          ) { }
          EOF
        }

        it 'has no problems' do
          expect(problems).to have(0).problems
        end

        context 'in one line' do
          let(:code) { "class puppet_module(String $alphabetical, String $non_alphabetical){ }" }

          it 'has no problems' do
            expect(problems).to have(0).problems
          end
        end

        context 'with hash parameters' do
          let(:code) { <<-EOF
            class puppet_module(
              Hash [String, String] $alphabetical,
              String $non_alphabetical
            ) { }
            EOF
          }

          it 'has no problems' do
            expect(problems).to have(0).problems
          end
        end
      end

      context 'not sorted alphabetically' do
        let(:code) { <<-EOF
          class puppet_module(
            String $non_alphabetical,
            String $alphabetical
          ) { }
          EOF
        }

        it 'has a problem' do
          expect(problems).to have(1).problems
        end
      end
    end

    context 'class with only optional parameters' do
      let(:code) { <<-EOF
        class puppet_module(
          String $alphabetical = default
        ) { }
        EOF
      }

      it 'has no problems' do
        expect(problems).to have(0).problems
      end

      context 'optional parameter from inherited class' do
        let(:code) { <<-EOF
          class puppet_module(
            String $alphabetical = $puppet_module::params::alphabetical
          ) inherits puppet_module::params { }
          EOF
        }

        it 'has no problems' do
          expect(problems).to have(0).problems
        end
      end

      context 'optional parameter initialized with function' do
        let(:code) { <<-EOF
          class puppet_module(
            Hash [String, String] $users = hiera_hash('some::hieradata::key', {})
          ) { }
          EOF
        }

        it 'has no problems' do
          expect(problems).to have(0).problems
        end
      end
    end

    context 'class with required and optional parameters' do
      context 'sorted alphabetically per group' do
        let(:code) { <<-EOF
          class puppet_module(
            String $alphabetical,
            String $non_alphabetical,
            String $alphabetical_optional = "default",
            String $non_alphabetical_optional = "default"
          ) { }
          EOF
        }

        it 'has no problems' do
          expect(problems).to have(0).problems
        end
      end

      context 'not sorted alphabetically per group' do
        let(:code) { <<-EOF
          class puppet_module(
            String $non_alphabetical,
            String $alphabetical,
            String $non_alphabetical_optional = "default",
            String $alphabetical_optional = "default"
          ) { }
          EOF
        }

        it 'has two problems' do
          expect(problems).to have(2).problems
        end
      end

      context 'not sorted in groups' do
        let(:code) { <<-EOF
          class puppet_module(
            String $alphabetical_optional = "default",
            String $alphabetical,
            String $non_alphabetical_optional = "default"
          ) { }
          EOF
        }

        it 'has a problem' do
          expect(problems).to have(1).problems
        end
      end

      context 'not sorted in groups and not alphabetically' do
        let(:code) { <<-EOF
          class puppet_module(
            String $non_alphabetical,
            String $non_alphabetical_optional = "default",
            String $alphabetical,
            String $alphabetical_optional = "default"
          ) { }
          EOF
        }

        it 'has three problems' do
          expect(problems).to have(3).problems
        end
      end

      context 'with a double comma syntax error' do
        let(:code) { <<-EOF
          class puppet_module(
            String $alphabetical,
            String $alphabetical_optional = "default",,
          ) { }
          EOF
        }

        it 'has a problem' do
          expect(problems).to have(1).problems
        end
      end
    end
  end

  context 'with fix enabled' do
    before do
     PuppetLint.configuration.fix = true
    end

    after do
     PuppetLint.configuration.fix = false
    end

    context 'class with no parameters' do
      let(:code) { "class puppet_module() { }" }

      it 'does not change the code' do
        expect(manifest).to eq(code)
      end
    end

    context 'class sorted alphabetically' do
      let(:code) { <<-EOF
          class puppet_module(
            String $alphabetical,
            String $non_alphabetical
          ) { }
          EOF
      }
      it 'does not change the code' do
        expect(manifest).to eq(code)
      end
    end

    context 'multiple classes not sorted alphabetically' do
      let(:code) { <<-EOF
class puppet_module(
  String $non_alphabetical,
  String $alphabetical
) { }

class puppet_module2(
  String $non_alphabetical,
  String $alphabetical
) { }
EOF
      }

      it 'fixes the problem' do
        expect(manifest).to eq(<<-EOF
class puppet_module(
  String $alphabetical,
  String $non_alphabetical
) { }

class puppet_module2(
  String $alphabetical,
  String $non_alphabetical
) { }
EOF
        )
      end
    end

    context 'not sorted in groups and not alphabetically' do
      let(:code) { <<-EOF
class puppet_module(
  String $non_alphabetical,
  String $non_alphabetical_optional = $puppet_module::params::non_alphabetical_optional,
  String $alphabetical,
  String $alphabetical_optional = "default"
) inherits puppet_module::params { }
EOF
      }

      it 'fixes the problem' do
        expect(manifest).to eq(<<-EOF
class puppet_module(
  String $alphabetical,
  String $non_alphabetical,
  String $alphabetical_optional = "default",
  String $non_alphabetical_optional = $puppet_module::params::non_alphabetical_optional
) inherits puppet_module::params { }
EOF
        )
      end
    end

    context 'with documented parameters not sorted alphabetically' do
      let(:code) { <<-EOF
#
# @param non_alphabetical The non_alphabetical parameter
# @param alphabetical The alphabetical parameter
#
class puppet_module(
  String $non_alphabetical,
  String $alphabetical
) { }

#
# @param non_alphabetical The non_alphabetical parameter
# @param alphabetical The alphabetical parameter
#
class puppet_module2(
  String $non_alphabetical,
  String $alphabetical
) { }
EOF
      }

      it 'fixes the problem' do
        expect(manifest).to eq(<<-EOF
#
# @param alphabetical The alphabetical parameter
# @param non_alphabetical The non_alphabetical parameter
#
class puppet_module(
  String $alphabetical,
  String $non_alphabetical
) { }

#
# @param alphabetical The alphabetical parameter
# @param non_alphabetical The non_alphabetical parameter
#
class puppet_module2(
  String $alphabetical,
  String $non_alphabetical
) { }
EOF
        )
      end
    end
  end
end
