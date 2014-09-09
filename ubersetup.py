#! /usr/bin/env python
from subprocess import Popen, PIPE, STDOUT
from os import path, mkdir
import platform
import argparse
import urllib
import zipfile
from shutil import rmtree

os_type = platform.system()
python_version = platform.python_version_tuple()
python_bitness = platform.architecture()[0]

this_directory = path.dirname(path.realpath(__file__))
"""Path where this script is located"""
tmp_dir = path.join(this_directory, 'temp')
"""Install temporary directory"""
PIP_INSTALL_SINGLE = 'pip install {0}'
"""PIP-command to install a single package"""
PIP_INSTALL_FILE = 'pip install -r {0}'
"""PIP-command to install packages from a file description""" 
PIP_LIST = 'pip list'
"""PIP-command to list all installed packages"""
PIP_UNINSTALL = 'pip uninstall -y {0}'
"""PIP-command to silently delete a package"""

def runcommand (command, workingdir=this_directory, suppress_output=False):
    """Run a command on the command line"""
    
    handle = Popen(command, shell=True, stdout=PIPE,
                              stderr=STDOUT, cwd=workingdir)
        
    output = []
    while handle.poll() is None:
        line = handle.stdout.readline().strip()
        if line:
            if not suppress_output:
                print line
            output.append(line)
                
    return output

def smkdir (directory):
    """Try to create a directory and do nothing if directory
    already exists"""
    try:
        mkdir(directory)
    except OSError:
        pass

def test_if_package_installed (package):
    for line in runcommand(PIP_LIST, suppress_output=True):
        if package.lower() in line.lower():
            return True
    return False

def install_package (package, ost, osb, pyv, ptype, src):
    
    if test_if_package_installed (package):
        print 'Package {0} already installed'.format(package)
        return False
    else:
        print 'Package {0} will be installed'.format(package)
    
    allowed_ptypes = [ 'wheel', 'install' ]
    if not os_type.lower() in ost.lower():
        print 'Package {0} skipped because of required variable {1}'.format(src, ost)
        return False
    if not osb in python_bitness:
        print 'Package {0} skipped because of required variable {1}'.format(src, osb)
        return False
    pyv_array = pyv.split('.')
    if not int(pyv_array[0]) >= int(python_version[0]):
        print 'Package {0} skipped because of required variable {1}'.format(src, python_version)
        return False
    if not int(pyv_array[1]) >= int(python_version[1]):
        print 'Package {0} skipped because of required variable {1}'.format(src, python_version)
        return False
    if not ptype in allowed_ptypes:
        print 'Package {0} skipped because of required variable {1}'.format(src, allowed_ptypes)
        return False
    trg_file = path.join(tmp_dir, path.basename(src))
    urllib.urlretrieve(src, trg_file)
    if ptype == 'wheel':
        runcommand('wheel install {0}'.format(trg_file))
        return True
    elif ptype == 'install':
        runcommand('{0}'.format(trg_file))
        return True
    else:
        return False

def ubersetup_system ():

    print '=== Preparing environment'
    
    print 'You\'re running on\nOS type: {0}\nPython version: {1}\nPython bitness: {2}'.format(os_type, python_version, python_bitness)
    
    smkdir(tmp_dir)
    
    print '=== Installiung pip using python'
    if not test_if_package_installed('pip'):
        pip_install_script = path.join(tmp_dir, 'get-pip.py')
        urllib.urlretrieve ('https://bootstrap.pypa.io/get-pip.py', pip_install_script)
        runcommand (pip_install_script, tmp_dir)
    else:
        print 'Package pip already installed.'
        
    runcommand(PIP_INSTALL_FILE.format(path.join(this_directory, 'setup-requirements.txt')))

    print '=== Installing bastis python toolbox'

    if not test_if_package_installed('bptbx'):
        bptbx_dir = path.join (tmp_dir, 'bptbx') 
        smkdir (bptbx_dir)
        urllib.urlretrieve ('https://github.com/BastiTee/bastis-python-toolbox/archive/master.zip', path.join(bptbx_dir, 'bptbx.zip'))
              
        with zipfile.ZipFile(path.join(bptbx_dir, 'bptbx.zip'), 'r') as z:
            z.extractall(bptbx_dir)
          
        extracted_dir = path.join(bptbx_dir, 'bastis-python-toolbox-master')
        runcommand ('{0} install'.format(path.join(extracted_dir, 'setup.py')), extracted_dir)
    else:
        print 'Package bptbx already installed.'
        
    print '=== Installing os specific dependencies'
    
    install_package(package='numpy', ost='windows', osb='32', pyv='2.7', ptype='install', src='http://sourceforge.net/projects/numpy/files/NumPy/1.9.0/numpy-1.9.0-win32-superpack-python2.7.exe')
    install_package(package='twain', ost='windows', osb='32', pyv='2.7', ptype='install', src='https://pypi.python.org/packages/2.7/t/twain/twain-1.0.5.win32-py2.7.exe')
    install_package(package='pycrypto', ost='windows', osb='32', pyv='2.7', ptype='install', src='http://www.voidspace.org.uk/downloads/pycrypto26/pycrypto-2.6.win32-py2.7.exe')
    install_package(package='reportlab', ost='windows', osb='32', pyv='2.7', ptype='wheel', src='https://pypi.python.org/packages/2.7/r/reportlab/reportlab-3.1.8-cp27-none-win32.whl')
    install_package(package='matplotlib', ost='windows', osb='32', pyv='2.7', ptype='wheel', src='https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.4.0/matplotlib-1.4.0-cp27-none-win32.whl')
    
    print '=== Installing local dependencies '
      
    runcommand(PIP_INSTALL_FILE.format(path.join(this_directory, 'package-requirements.txt')))
    
    print '=== Resolving necessary packages from own Git projects'
    runcommand(PIP_INSTALL_FILE.format('https://raw.githubusercontent.com/BastiTee/pyntrest/master/requirements.txt'))
    runcommand(PIP_INSTALL_FILE.format('https://raw.githubusercontent.com/BastiTee/bastis-python-toolbox/master/requirements.txt'))
        
    print '=== Finalize setup'
    rmtree(tmp_dir)
    
    runcommand(PIP_LIST)

def uberclear_system ():
    try:
        for line in runcommand(PIP_LIST, suppress_output=True):
            if not 'pip' in line:
                runcommand(PIP_UNINSTALL.format(line.split()[0]))
    except ImportError:
        pass
    # TODO Uninstall PIP

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Ubersetup your python environment.')
    parser.add_argument('--mode', dest='mode', help='Ubermode selection', choices=['setup', 'clear'])
    args = parser.parse_args()
    
    if not args.mode:
        parser.print_help()
        exit(0)
        
    if args.mode == 'setup':
        ubersetup_system()
    else:
        uberclear_system()
