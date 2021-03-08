# XVC for pynq-z2

Refer to Xilinx official documentation: [Xiilnx Virtual Cable(XVC)](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug973-vivado-release-notes-install-license.pdf) .

I'd like to make a similar one for [TUL pynq-z2 development board](https://www.tul.com.tw/ProductsPYNQ-Z2.html) with [non project TCL mode (page 22)](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_2/ug892-vivado-design-flows-overview.pdf).

## 1 How to build hw

### 1.0 Before build

First,

make sure that the *Vivado* `bin` directory already exists in the `{PATH} of env.var`

You have 2 ways to build *hw*

1. vivado tcl-cli mode
2. vivado tcl-batch mode

The following sections (1.1, 1.2) will explain.

### 1.1 Using *vivado tcl-cli mode*

``` bash
# Using bash in the root directory of this project
$ mkdir build
$ cd build
$ vivado -mode tcl
```

After entry to the *Vivado tcl command line*

``` tclsh
# in the vivado tcl command line
Vivado% source ../src/hw/script/top.tcl
```

Or you can build before entry *Vivado tcl command line*

``` bash
# Using bash in the root directory of this project
$ mkdir build
$ cd build
$ vivado -mode tcl -source ../src/hw/script/top.tcl
```

After build, you can open GUI to check report

``` tclsh
# in the vivado tcl command line
Vivado% start_gui
```

### 1.2 Using *vivado tcl-batch mode*

``` bash
# Using bash in the root directory of this project
$ mkdir build
$ cd build
$ vivado -mode batch -source ../src/hw/script/top.tcl
```

### 1.3 Tips to reduce hardware build time

#### 1.3.1 Filter generated reports

You may have seen `report_****` in the `top.tcl`,

this command for generate report of build Vivado project.

Maybe not all reports are what you need,

therefore you can **Comment (#) report_\*\*\*\*** to reduce reports output,

then time of build also could be reduced.

#### 1.3.2 `write_checkpoint` maybe you don't need

From [Vivado Design Suite TclCommand Reference Guide, page 1800](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug835-vivado-tcl-commands.pdf),

explain the function about `write_checkpoint`

> Saves the design at any point in the design process, \
> so that you can quickly import it back into thetool as needed. \
> A design checkpoint (DCP) can contain \
> the netlist, the constraints, and any placement and routing information \
> from the implemented design.

The `.dcp` file need to write to disk,

compiler could interactive between disk and RAM,

so time cost of build could be increase since *write `.dcp` files to disk*

if we compile once to end (e.g. Using *vivado tcl-batch mode*),

and recomplie also clean all of previous generated object,

`write_checkpoint` maybe you don't need.

## 2 How to build sw

### 2.1 Prepare Petalinux

#### 2.1.0 Petalinux-tools only can be run on the Linux platform

#### 2.1.1. Download [Xilinx Petalinux tools](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html)

#### 2.1.2 Before execute Petalinux-tools, please ensure that [Dependencies](https://wiki.archlinux.org/index.php/Xilinx_Vivado#Dependencies_for_petalinux-tools) has been installed

#### 2.1.3 Please also ensure the version of petalinux-tools is same to vivado

#### 2.1.4 Go to directory of downloaded petalinux-tools, install with **user** in yout terminal

``` bash
$ chmod +x ./petalinux-v<petalinux-version>-final-installer.run
$ ./petalinux-v<petalinux-version>-final-installer.run --dir <INSTALL_DIR>
#(I recommend settting <INSTALL_DIR> to `/home/<user>`)
```

#### 2.1.5 Append following **env.var** to *.bashrc*

``` bash
source /<dir-to-step5-installed>/settings.sh
export PATH=$PATH:/tools/Xilinx/Vivado/2019.2/bin
export PATH=$PATH:/tools/Xilinx/Vitis/2020.2/bin
```

#### 2.1.6 Build header of Vitis-gcc

``` bash
sudo /tools/Xilinx/Vivado/2020.2/lnx64/tools/gcc/libexec/gcc/x86_64-unknown-linux-gnu/4.6.3/install-tools/mkheaders /tools/Xilinx/Vivado/2020.2/lnx64/tools/gcc 
```

### 2.2 Build with build script

0. Please **build hw** first
1. After **build hw**, you should get a file `./build/<outdir>/*.hdf`
2. Switch to bash, petalinux-tools **only support bash**, therefore do `$ bash`
3. Start to build sw

``` bash
source ../src/sw/script/top.sh xvc_linux ./out/xvc_system_top.xsa
```

## FAQ

## Contributer

Founder: DeWei\<dewei@hep1.phys.ntu.edu.tw\>, RA, HEP-Phys-NTU
