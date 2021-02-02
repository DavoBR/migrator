import glob
import os

exePath = glob.glob('*.exe')[0]
exeName = os.path.basename(exePath)

print(f'::set-output name=path::{exePath}')
print(f'::set-output name=name::{exeName}')