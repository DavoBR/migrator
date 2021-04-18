import re 
import os

def file_read(path):
  f = open(path, 'r')
  data = f.read()
  f.close()
  return data

def file_write(path, data):
  f = open(path, 'w')
  f.write(data)
  f.close()

version = os.environ.get('VERSION')
branchName = os.environ.get('BRANCH_NAME')

print(f'VERSION: {version}')
print(f'BRANCH_NAME: {branchName}')

match = re.search(r'(\d+)\.(\d+)\.(\d+)', version)
version = match.group(0)
major = match.group(1)
minor = match.group(2)
patch = match.group(3)
longVersion = f'{version}-{branchName}'

print(f'::set-output name=major::{major}')
print(f'::set-output name=minor::{minor}')
print(f'::set-output name=patch::{patch}')
print(f'::set-output name=long::{longVersion}')

file_path = './windows/runner/Runner.rc'

print(f'::debug Define version in {file_path}')

file_data = file_read(file_path)
file_data = re.sub(r'VERSION_AS_NUMBER \d+,\d+,\d+', f'VERSION_AS_NUMBER {version.replace(".", ",")}', file_data)
file_data = re.sub(r'VERSION_AS_STRING "\d+\.\d+\.\d+"', f'VERSION_AS_STRING "{longVersion}"', file_data)

file_write(file_path, file_data)

file_path = './installer/script.nsi'

print(f'::debug Define version in {file_path}')

file_data = file_read(file_path)
file_data = re.sub(r'!define VERSIONMAJOR \d+', f'!define VERSIONMAJOR {major}', file_data)
file_data = re.sub(r'!define VERSIONMINOR \d+', f'!define VERSIONMINOR {minor}', file_data)
file_data = re.sub(r'!define VERSIONBUILD \d+', f'!define VERSIONBUILD {patch}', file_data)

file_write(file_path, file_data)


file_path = './lib/utils/constants.dart'

print(f'::debug Define version in {file_path}')

file_data = file_read(file_path)
file_data = re.sub('APP_VERSION "debug"', f'APP_VERSION "v{longVersion}"', file_data)

file_write(file_path, file_data)
