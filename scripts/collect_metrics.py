import os
import glob

print("Listing raw results collected:")
for filepath in sorted(glob.glob("results/raw/**/*.txt", recursive=True)):
    print(f" - {filepath}")
