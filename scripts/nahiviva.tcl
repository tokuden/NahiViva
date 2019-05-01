variable version        "0.14"
variable date           "H31/5/1"
variable create_script  "create_project.tcl"

proc print_help {} {
  variable script_file
  puts {Description:}
  puts {  �����Vivado�̍�����IP�A�b�v�f�[�g������������X�N���v�g�ł�}
  puts {Syntax:}
  puts {  NahiRun [<option>]      Synth and Impl active run.}
  puts {  NahiUpdate              Refresh IP catalog and update IP core.}
  puts {  NahiChild [<name>]      Open and edit IP core project.}
  puts {  NahiPackage             Re-Package IP. (use in IP core project)}
  puts {  NahiSave                Write tcl to re-create project.}
}

proc _NahiSearchProject {} {
	# ���݂̃f�B���N�g����T��
	set dirs [glob *]
	foreach path $dirs {
		if [file isfile $path] {
			if {[file extension $path] == ".xpr"} {
				return $path;
			}
		}
	}
	# �T�u�f�B���N�g����T��
	foreach path $dirs {
		if [file isdirectory $path] {
			if {[string index $path 0] == "."} {continue} #.�Ŏn�߂�f�B���N�g���͒��ׂȂ�
			if {$path == "ip_repo"} {continue} #ip_repo�͒��ׂȂ�
			set subdirs [glob ${path}/*]
			foreach subpath $subdirs {
				if [file isfile $subpath] {
					if {[file extension $subpath] == ".xpr"} {
						return $subpath;
					}
				}
			}
		}
	}
	return ""
}

proc _NahiOpenProject {{type ""}} {
	set project_file [_NahiSearchProject]
	if {$project_file == ""} {
		puts "---------------------------------------------------------"
		puts "ERROR:Could not find .xpr project file."
		puts "---------------------------------------------------------"
		return 0
	}
	open_project $project_file

	if {$type == "gui"} {
		puts "GUI�ŊJ���܂�"
		start_gui
	}
	update_compile_order -fileset sources_1
#	open_bd_design "$project_directory/project_1.srcs/sources_1/bd/design_1/design_1.bd"
	return 1
}

proc NahiRun {args} {
	# current_run���猻�݂�impl�̖��O�𓾂�
	set report 0
	set run_name [current_run]
	set run [get_runs $run_name]
	if {[get_property IS_IMPLEMENTATION $run] == 1} {
		set impl $run_name;
		# synth�̖��O��impl��PARENT�ɓ����Ă���
		set synth [get_property PARENT $run]
	}

	foreach op $args {
		if {$op == "-help"} {
			puts {NahiRun [<option>]}
			puts "Option:"
			puts "     -update      Update IP before Synthsize"
			puts "     -restart     Reset Run and Restart"
			puts "     -report      Open Implementation and make reports."
			puts "     -help        Show this help"
		}
		if {$op == "-update"} {
			puts "�R�A���X�V���܂�"
			NahiUpdate
		}
		if {$op == "-restart"} {
			puts "RUN�����������܂�"
			reset_runs $synth
			reset_runs $impl
		}
		if {$op == "-report"} {
			set $report 1
		}
	}

	set obj [get_runs $synth]
	set needs [get_property NEEDS_REFRESH $obj]
	set prog [get_property PROGRESS $obj]
	if {($needs == 0 && $prog == "100%")} {
		puts "-------------------------------------------------------------------------"
		puts "�_�������̕K�v�͂���܂���"
		puts "-------------------------------------------------------------------------"
	} else {
		puts "-------------------------------------------------------------------------"
		puts "�_���������J�n���܂�"
		puts "-------------------------------------------------------------------------"
		reset_runs $synth
		launch_runs $synth
		wait_on_run $synth
		if {[get_property PROGRESS [get_runs $synth]] != "100%"} {
			error "ERROR: �_������ $synth �Ɏ��s���܂���"
			return 0
		}
	}

	set obj [get_runs $impl]
	set needs [get_property NEEDS_REFRESH $obj]
	set prog [get_property PROGRESS $obj]
	if {($needs == 0 && $prog == "100%")} {
		puts "-------------------------------------------------------------------------"
		puts "�z�u�z���̕K�v�͂���܂���"
		puts "-------------------------------------------------------------------------"
	} else {
		puts "-------------------------------------------------------------------------"
		puts "�z�u�z�����J�n���܂�"
		puts "-------------------------------------------------------------------------"
		reset_runs $impl
		launch_runs $impl
		wait_on_run $impl
		if {[get_property PROGRESS [get_runs $impl]] != "100%"} {
			error "ERROR: �z�u�z�� $impl �Ɏ��s���܂���"
			return 0
		}
	}

	set project_directory [get_property DIRECTORY [current_project]]
	if {$report == 1} {
		open_run  $impl
		report_utilization -file [file join $project_directory "rpt_utilization.txt" ]
		report_timing      -file [file join $project_directory "rpt_timing.txt" ]
		report_io          -file [file join $project_directory "rpt_io.txt" ]
	}

	puts "-------------------------------------------------------------------------"
	puts "�r�b�g�X�g���[���𐶐����܂�"
	puts "-------------------------------------------------------------------------"
	launch_runs $impl -to_step write_bitstream -job 4
	wait_on_run $impl

	set bitsteam_dir [get_property DIRECTORY [current_run]]
	set bitfile [file join $bitsteam_dir "[get_property top [get_filesets sources_1]].bit"]
	file copy -force $bitfile [file join ../ $project_directory]
	
	return 1
}

proc _NahiUserLock { {lock 1} } {
	foreach cell [get_bd_cells] {
		set_property LOCK_UPGRADE $lock [get_bd_cells $cell]
	}
}

proc NahiUpdate { } {
	foreach cell [get_bd_cells] {
		set_property LOCK_UPGRADE 0 [get_bd_cells $cell]
	}

	update_ip_catalog -rebuild -repo_path [get_property  ip_repo_paths [current_project]]
	report_ip_status 
	foreach ip [get_ips] {
		export_ip_user_files -of_objects [get_ips $ip] -no_script -sync -force -quiet
		upgrade_ip  [get_ips $ip] -log ip_upgrade.log
	}
	report_ip_status
	report_ip_status -name ip_status 
}

proc _NahiShowAllProperty {{objname ""}} {
	if {$objname == ""}  {
		set obj [current_project]
	} else {
		set obj $objname
	}
	set keys [list_property $obj]
	foreach {w} $keys {
		set r [get_property $w $obj];
		puts "$w <= $r"
	}
}

proc NahiChild {{ip_name ""}} {
	if {$ip_name == ""} {
		puts "usage: NahiChild <ip_name>"
		return
	}
	set project_directory [get_property DIRECTORY [current_project]]
	set project_name [get_property NAME [current_project]]
	set tmpdir [file join [file join $project_directory tmp] ${ip_name}_project]
	set repopath [get_property ip_repo_paths [current_project]]
	
	ipx::edit_ip_in_project -upgrade true -name ${ip_name}_project -directory $tmpdir [file join $repopath $ip_name/component.xml]
}

proc NahiPackage {} {
#	update_compile_order -fileset sources_1
	set new_version [expr [get_property core_revision [ipx::current_core]]+1]
	set_property core_revision $new_version [ipx::current_core]
	ipx::update_source_project_archive -component [ipx::current_core]
	ipx::create_xgui_files [ipx::current_core]
	ipx::merge_project_changes ports [ipx::current_core]
	ipx::update_checksums [ipx::current_core]
	ipx::save_core [ipx::current_core]
	ipx::move_temp_component_back -component [ipx::current_core]
}

proc NahiSave {} {
	set project_directory [get_property DIRECTORY [current_project]]
	set script_dir [file join ${project_directory} "../"]
	puts $script_dir
	write_project_tcl -no_copy_sources -use_bd_files -force [file join $script_dir create_project.tcl]
}

proc _NahiInit {} {
	variable version
	variable date
	variable create_script
	
	puts " ######################################################################"
	puts "   Nahitafu Vivado Utility Script                                      "
	puts "    Version $version $date" 
	puts "   (C)2019 �ȂЂ���  Twitter:@nahitafu"
	puts " ######################################################################"
	print_help
	
	if { $::argc > 0 } {
		for {set i 0} {$i < $::argc} {incr i} {
			set option [string trim [lindex $::argv $i]]
			if {$option == "delete_project"} {
				set project [_NahiSearchProject]
				if {$project == ""} {
					puts "�v���W�F�N�g��������܂���"
					after 2000
					exit
				}
				set project_dir [file normalize [file dirname $project]]
				puts "--------------------------------------------------------------------" 
				puts "�f�B���N�g�� ${project_dir} ���폜���܂����H (y/N)" 
				set keyin [gets stdin]
				if {$keyin == "y"} {
					puts "$project_dir���폜���܂�"
					file delete -force $project_dir
					puts ".Xil���폜���܂�"
					file delete -force ".Xil"
					after 2000
					exit
				} else {
					puts "�폜�͒��~����܂���"
					after 2000
					exit
				}
			}
			if {$option == "open"} {
				if {[_NahiOpenProject] == 0} {
					source $create_script
					close_project
					if {[_NahiOpenProject] == 0} {
						puts "�v���W�F�N�g�̐����Ɏ��s���܂���"
						after 2000
						exit 0
					}
				}
			}
			if {$option == "opengui"} {
				if {[_NahiOpenProject gui] == 0} {
					source $create_script
					close_project
					if {[_NahiOpenProject gui] == 0} {
						puts "�v���W�F�N�g�̐����Ɏ��s���܂���"
						after 2000
						exit 0
					}
				}
			}
		}
	}
}

_NahiInit