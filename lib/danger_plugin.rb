module Danger
  # Enforce linear history inside your project.
  #
  # @example Running with warnings
  #
  #          # Enforces linear history, but does not fail the pull request
  #          # linear_history.validate!(soft_fail: true)
  #          linear_history.validate!
  #
  # @example Running with errors
  #
  #          # Enforces linear history, failing the pull request if applicable
  #          linear_history.validate!(soft_fail: false)
  #
  # @see  tootbot/tootbot
  # @tags git
  #
  class LinearHistory < Plugin
    # Validates the pull request commits to ensure linear history.
    #
    # @param  [Bool] soft_fail
    #                Toggles output behavior between warn and fail.
    #                Defaults to true (warn).
    #
    # @return [void]
    #
    def validate!(soft_fail: true)
      return unless commits.any? { |commit| commit.parents.length > 1 }

      message = 'Please rebase to get rid of the merge commits in this PR'

      if soft_fail
        warn message
      else
        fail message
      end
    end
  end
end
