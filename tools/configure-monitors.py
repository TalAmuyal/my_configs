#!/usr/bin/python3

import subprocess
import argparse
import os
import re


def getOutputs():
    process = subprocess.run(
        ['xrandr'],
        stdout=subprocess.PIPE,
        universal_newlines=True,
    )
    outputs = []
    for line in process.stdout.split('\n'):
        name_match = re.search(r'^(.+)\s+connected', line)
        if name_match:
            outputs.append(name_match.group(1))
    return outputs


def setSingleMonitor(activate, deactivateList):
    print('Setting %s as the primary and only monitor' % (activate))
    command = 'xrandr --output %s --primary --auto --pos 0x0' % (activate)
    for output in deactivateList:
        print('Shutting ', output)
        command += ' --output %s --off' % (output)
    print('xrandr command: ', command)
    result = os.system(command)
    if result != 0:
        print("xrandr failed with return code: %d" % result)
        exit(result)


if __name__ == "__main__":
    outputs = getOutputs()
    if len(outputs) < 1:
        print('No output devices found, aborting')
        exit(1)

    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=False)
    group.add_argument('-l', '--list', action='store_true', default=False, help="List the available displays")
    group.add_argument('-s', '--set',  choices=outputs,     default=None,  help="Set the specified monitor as the only one for use")
    args = parser.parse_args()

    if args.list:
        if len(outputs) < 1:
            outputs = ['None']
        print('Outputs:')
        for output in outputs:
            print(' - ', output)
    elif args.set:
        outputs.remove(args.set)
        setSingleMonitor(args.set, outputs)
    else:
        setSingleMonitor(outputs[-1], outputs[:-1])

