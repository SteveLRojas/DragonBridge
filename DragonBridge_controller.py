import sys
import serial 
import time

####################
# Constants        #
####################
#DragonBridge commands
CMD_NOP = "00"				#Expects 0 bytes, returns 0
CMD_TEST = "01"				#Expects 1 byte, returns 1
CMD_BAUD = "02"				#Expects 2 bytes, returns 0
	
CMD_SPI_SPEED = "03"		#Expects 1 byte, returns 0
CMD_SPI_MODE = "04"			#Expects 1 byte, returns 0
CMD_SPI_CHIPSEL = "05"		#Expects 1 byte, returns 0
CMD_SPI_TRANSFER = "06"		#Expects 1 byte, returns 1
	
CMD_I2C_SPEED = "07"		#Expects 2 bytes, returns 0
CMD_I2C_START = "08"		#Expects 0 bytes, returns 0
CMD_I2C_STOP = "09"			#Expects 0 bytes, returns 0
CMD_I2C_WRITE = "0A"		#Expects 1 byte, returns 0
CMD_I2C_READ = "0B"			#Expects 0 bytes, returns 1
CMD_I2C_HOST_ACK = "0C"		#Expects 1 byte, returns 0
CMD_I2C_AGENT_ACK = "0D"	#Expects 0 bytes, returns 1

# CLI Commands
FILE = 0
BAUD = 1
PORT = 2

def print_usage():
	print("Usage: -FILE <script file> -BAUD <baud rate> -PORT <serial port> -DEBUG")
	print("-BAUD, -PORT, and -DEBUG are optional")
	print("Default baud rate is 115200, and default port is COM1")

def str_comp_partial(first, second):
	length = len(first)
	if len(second) < length:
		length = len(second)
	return first[0:length] == second[0:length]

def do_nop(debug, ser):
	if(debug):
		print("NOP")
	ser.write(bytes.fromhex(CMD_NOP))

def do_test(debug, ser, args):
	if(debug):
		print("TEST")
	ser.write(bytes.fromhex(CMD_TEST))
	ser.write(bytes.fromhex(args))
	res = ser.read(1)
	print("".join(format(res[0], "02X")))

def do_baud(debug, ser, args):
	if(debug):
		print("BAUD")
	ser.write(bytes.fromhex(CMD_BAUD))
	ser.write(bytes.fromhex(args))

def do_spi_speed(debug, ser, args):
	if(debug):
		print("SPI_SPEED")
	ser.write(bytes.fromhex(CMD_SPI_SPEED))
	ser.write(bytes.fromhex(args))

def do_spi_mode(debug, ser, args):
	if(debug):
		print("SPI_MODE")
	ser.write(bytes.fromhex(CMD_SPI_MODE))
	ser.write(bytes.fromhex(args))

def do_spi_chipsel(debug, ser, args):
	if(debug):
		print("SPI_CHIPSEL")
	ser.write(bytes.fromhex(CMD_SPI_CHIPSEL))
	ser.write(bytes.fromhex(args))

def do_spi_transfer(debug, ser, args):
	if(debug):
		print("SPI_TRANSFER")
	ser.write(bytes.fromhex(CMD_SPI_TRANSFER))
	ser.write(bytes.fromhex(args))
	res = ser.read(1)
	print("".join(format(res[0], "02X")))

def do_i2c_speed(debug, ser, args):
	if(debug):
		print("I2C_SPEED")
	ser.write(bytes.fromhex(CMD_I2C_SPEED))
	ser.write(bytes.fromhex(args))

def do_i2c_start(debug, ser):
	if(debug):
		print("I2C_START")
	ser.write(bytes.fromhex(CMD_I2C_START))

def do_i2c_stop(debug, ser):
	if(debug):
		print("I2C_STOP")
	ser.write(bytes.fromhex(CMD_I2C_STOP))

def do_i2c_write(debug, ser, args):
	if(debug):
		print("I2C_WRITE")
	ser.write(bytes.fromhex(CMD_I2C_WRITE))
	ser.write(bytes.fromhex(args))

def do_i2c_read(debug, ser):
	if(debug):
		print("I2C_READ")
	ser.write(bytes.fromhex(CMD_I2C_READ))
	res = ser.read(1)
	print("".join(format(res[0], "02X")))

def do_i2c_host_ack(debug, ser, args):
	if(debug):
		print("I2C_HOST_ACK")
	ser.write(bytes.fromhex(CMD_I2C_HOST_ACK))
	ser.write(bytes.fromhex(args))

def do_i2c_agent_ack(debug, ser):
	if(debug):
		print("I2C_AGENT_ACK")
	ser.write(bytes.fromhex(CMD_I2C_AGENT_ACK))
	res = ser.read(1)
	print("".join(format(res[0], "02X")))

def run_script(script_path, debug, ser):
	line_count = 0
	script = open(script_path, 'r')
	
	for line in script:
		line_count = line_count + 1
		split_line = line.replace('\n', '').split(':')
		command = split_line[0].replace(' ', '').replace('\t', '').upper()

		if(len(split_line) == 2):
			args = split_line[1]
			clean_args = args.replace(' ', '').replace('\t', '').upper()

			if(command == "NOP"):
				do_nop(debug, ser)
			elif(command == "TEST"):
				do_test(debug, ser, clean_args)
			elif(command == "BAUD"):
				do_baud(debug, ser, clean_args)
			elif(command == "SPI_SPEED"):
				do_spi_speed(debug, ser, clean_args)
			elif(command == "SPI_MODE"):
				do_spi_mode(debug, ser, clean_args)
			elif(command == "SPI_CHIPSEL"):
				do_spi_chipsel(debug, ser, clean_args)
			elif(command == "SPI_TRANSFER"):
				do_spi_transfer(debug, ser, clean_args)
			elif(command == "I2C_SPEED"):
				do_i2c_speed(debug, ser, clean_args)
			elif(command == "I2C_START"):
				do_i2c_start(debug, ser)
			elif(command == "I2C_STOP"):
				do_i2c_stop(debug, ser)
			elif(command == "I2C_WRITE"):
				do_i2c_write(debug, ser, clean_args)
			elif(command == "I2C_READ"):
				do_i2c_read(debug, ser)
			elif(command == "I2C_HOST_ACK"):
				do_i2c_host_ack(debug, ser, clean_args)
			elif(command == "I2C_AGENT_ACK"):
				do_i2c_agent_ack(debug, ser)
			elif(command == "REM"):
				print(args.strip())
			else:
				print("Warning: Invalid command %s at line %s" % (split_line[0], str(line_count)))
		elif(command):
			print("Warning: Line %s is invalid!" % (str(line_count)))

def main():
	file_path = ""
	baud = 115200
	port = "COM1"
	path_idx = 0
	debug = 0

	if(len(sys.argv) == 1):
		print_usage()
		exit(0);

	for arg in sys.argv[1:]:
		clean_arg = arg.upper()
		#print(clean_arg)

		if(clean_arg[0] == '-'):
			if str_comp_partial("-FILE", clean_arg):
				path_idx = FILE
			elif str_comp_partial("-BAUD", clean_arg):
				path_idx = BAUD
			elif str_comp_partial("-PORT", clean_arg):
				path_idx = PORT
			elif str_comp_partial("-DEBUG", clean_arg):
				debug = 1
			else:
				print("Invalid argument %s" % (clean_arg))
				print_usage()
				exit(1)
		else:
			if(path_idx == FILE):
				file_path = arg
			elif(path_idx == BAUD):
				baud = int(arg)
			elif(path_idx == PORT):
				port = arg
			path_idx = 0

	if(debug):
		print("File path: %s" % (file_path))

	if(file_path):
		ser = serial.Serial()
		ser.baudrate = baud
		ser.port = port
		ser.dsrdtr = False
		ser.dtr = False
		ser.timeout = 1
		ser.open()
		run_script(file_path, debug, ser)
	else:
		print("No script specified!")
		exit(1)

	print("Done!")
	ser.close()

if __name__ == "__main__":
	main()
