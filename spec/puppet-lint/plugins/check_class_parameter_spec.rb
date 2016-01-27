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
    end
  end
end
