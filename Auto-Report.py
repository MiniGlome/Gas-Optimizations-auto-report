# Author:	MiniGlome (Mlome)
# Twitter:	https://twitter.com/0xMlome
# Email: 	MiniGlome@protonmail.com

import os
import sys
import re
import json
from Issues import issues

def list_solidity_files(repo):
	solidity_files = []
	for root, dirs, files in os.walk(repo):
		for file in files:
			if ".sol" in file:
				solidity_files.append(os.path.join(root, file))
	return solidity_files

def find_gas_optimisations(files, issue):
	print(f"[+] Parsing issue: {issue['code']}")
	instances = []
	total_instances = 0
	for file in files:
		# print(f"[+] File = {file}")
		with open(file, "r", encoding="utf-8") as f:
			txt = f.read()

		file_instances = []
		for match in re.finditer(issue["regex"], txt):
			s = match.start()
			e = match.end()
			n_line_s = txt[:s].count("\n")
			n_line_e = txt[:e].count("\n")
			line = "\n".join(txt.split("\n")[n_line_s:n_line_e+1])
			file_instances.append({"s":s, "e":e, "n_line":n_line_s+1, "match":txt[s:e], "line":line})

		if len(file_instances) > 0:
			total_instances += len(file_instances)
			print(f"{len(file_instances)} instances found in {file}")
			instances.append({"file": file, "instances": file_instances})

	return instances, total_instances


def create_report(title, gas_optimizations):
	report = "## Gas Optimizations\n| |Issue|Instances|\n|-|:-|:-:|\n"
	i = 1
	for issue in gas_optimizations:
		if issue['n'] > 0:
			report += f"| [GAS-{str(i).zfill(2)}] | {issue['issue']} | {issue['n']} | \n"
			i += 1

	report += "\n"
	i = 1
	for issue in gas_optimizations:
		if issue['n'] > 0:
			report += f"### [GAS-{str(i).zfill(2)}] {issue['issue']}\n"
			report += f"{issue['description']}\n\n"
			report += f"*Instances ({issue['n']})*:\n"
			for file in issue["instances"]:
				# report += f"```solidity\nFile: {file['file'].split('/')[-1]}\n"
				filename = "/".join(file['file'].split('\\')[1:])
				report += f"```solidity\nFile: {filename}\n"
				for instance in file["instances"]:
					report += f"{instance['n_line']}:{instance['line']}\n\n"
				report += "```\n\n"
			i += 1

	with open(title, "w") as f:
		f.write(report)

if __name__ == '__main__':
	# Check if directory argument is provided
	if len(sys.argv) == 1:
		repo = "Test"
	elif len(sys.argv) == 2:
		repo = sys.argv[1]
	else:
		print("Usage: py Auto-Report.py <repo>")
		sys.exit(1)

	# Check if directory exists
	if not os.path.isdir(repo):
		print(f"Error: {repo} is not a directory")
		sys.exit(1)

	# List all files recursively
	files = list_solidity_files(repo)
	print(f"{len(files)} files found")
	gas_optimizations = []
	for issue in issues:
		instances, total_instances = find_gas_optimisations(files, issue)
		gas_optimizations.append({"issue": issue["title"], "description": issue["description"], "n": total_instances, "instances": instances})

	# gas_optimizations = json.loads(gas_optimizations)
	print(f"gas_optimizations = {json.dumps(gas_optimizations, indent=2)}")
	title = f"output/{repo.split('/')[-1]}_gas_report.md"
	create_report(title, gas_optimizations)
