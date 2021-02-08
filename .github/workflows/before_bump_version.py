import os

branchName = os.environ.get('SOURCE_BRANCH')

print(f'SOURCE_BRANCH: {branchName}')

branchName = branchName.replace('refs/heads/', '').replace('/', '-')
createRelease = 'true' if branchName == 'master' or branchName == 'ci' else 'false'

print(f'::set-output name=source_branch::{branchName}')
print(f'::set-output name=create_release::{createRelease}')