transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Steve/Workspace/cy2m_spi_controller {C:/Users/Steve/Workspace/cy2m_spi_controller/uart_gen2.v}
vlog -vlog01compat -work work +incdir+C:/Users/Steve/Workspace/cy2m_spi_controller {C:/Users/Steve/Workspace/cy2m_spi_controller/top_level.v}
vlog -vlog01compat -work work +incdir+C:/Users/Steve/Workspace/cy2m_spi_controller {C:/Users/Steve/Workspace/cy2m_spi_controller/controller_fsm.v}
vlog -vlog01compat -work work +incdir+C:/Users/Steve/Workspace/cy2m_spi_controller {C:/Users/Steve/Workspace/cy2m_spi_controller/spi_host.v}

vlog -sv -work work +incdir+C:/Users/Steve/Workspace/cy2m_spi_controller {C:/Users/Steve/Workspace/cy2m_spi_controller/testbench.sv}
vlog -vlog01compat -work work +incdir+C:/Users/Steve/Workspace/cy2m_spi_controller {C:/Users/Steve/Workspace/cy2m_spi_controller/spi_host.v}
vlog -vlog01compat -work work +incdir+C:/Users/Steve/Workspace/cy2m_spi_controller {C:/Users/Steve/Workspace/cy2m_spi_controller/spi_master.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 40 us
