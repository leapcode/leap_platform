# Contributed Files

## Commit Template

To install our commit template, use following command (use --global to use it in your global .gitconfig):

    git config commit.template "~/path_to_leap_platform/contrib/leap-commit-template"

To use for all projects:

    git config --global commit.template "~/path_to_leap_platform/contrib/leap-commit-template"

## Signing commits

We very much appreciate signed commits, you can stop forgetting it like this:

    git config commit.gpgsign true

To enable for all projects:

    git config --global commit.gpgsign true
