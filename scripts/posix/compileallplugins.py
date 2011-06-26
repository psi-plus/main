#!/usr/bin/python
#-*-coding=utf-8-*-
import os
 
curr_dir = os.getcwd()
dirlist = os.listdir(curr_dir)
plugin_dir = os.environ.get("HOME") + "/.local/share/Psi+/plugins/" 

def CompilePlugin(dirname):
	if dirname:
		plugin_path = curr_dir + "/" + dirname
		mccommand = "make clean"
		qmcommand = "qmake"
		mcommand = "make" 
		os.chdir(plugin_path)
		os.system(mccommand)
		os.system(qmcommand)
		os.system(mcommand) 
		command = "cp -u " + plugin_path + "/*.so " + plugin_dir
		try: 
			os.system(command)
		except:
			print "can't copy a library from %s" % plugin_path
		os.chdir(curr_dir)

for subdir in dirlist:
	if subdir:
		if os.path.isdir(os.path.join(curr_dir, subdir)):
			CompilePlugin(subdir)


