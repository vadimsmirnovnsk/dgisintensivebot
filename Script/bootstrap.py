#!/usr/bin/env python
import os
import logging
import argparse
import subprocess

logging.basicConfig(level=logging.INFO,
					format="%(asctime)s %(levelname)s %(message)s")

script_dir = os.path.dirname(os.path.realpath(__file__))
parse_dir = os.path.join(script_dir, "days")
diff_dir = os.path.join(script_dir, "diff")

def main():
	parser = create_parser()
	args = parser.parse_args()

	logging.debug("Passed arguments: {}".format(args))
	install_packages()

def create_parser():
	parser = argparse.ArgumentParser(description="Generating v4iOS module..")
	parser.add_argument("--name", "-n",
		help="Module name",
		default="")
	return parser

def install_packages():
	subprocess.check_call(["swift", "package", "generate-xcodeproj"]) 
	subprocess.check_call(["swift", "build"]) 

if __name__ == "__main__":
	main()