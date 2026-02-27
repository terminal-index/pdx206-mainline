import sys
import re

dts_path = '/tmp/pdx206-gpu-dsi.dts'

with open(dts_path, 'r') as f:
    content = f.read()

enable_nodes = [
    'display-subsystem@ae00000',
    'display-controller@ae01000',
    'dsi@ae94000',
    'phy@ae94400',
    'gpu@3d00000',
    'gmu@3d6a000',
    'clock-controller@3d90000', 
    'pcie@1c08000', 
    'pcie@1c10000', 
]

for node in enable_nodes:
    pattern = r'(' + re.escape(node) + r'\s*\{[^{}]*?)status = "disabled";'
    content = re.sub(pattern, r'\1status = "okay";', content, flags=re.DOTALL)

dsi_reg_patch = r'\1status = "okay";\n\t\t\t\tvdda-supply = <0x5c>;\n\t\t\t\trefgen-supply = <0xd5>;'
content = re.sub(r'(dsi@ae94000\s*\{[^{}]*?)status = "okay";', dsi_reg_patch, content, flags=re.DOTALL)

phy_reg_patch = r'\1status = "okay";\n\t\t\t\tvdds-supply = <0x5c>;'
content = re.sub(r'(phy@ae94400\s*\{[^{}]*?)status = "okay";', phy_reg_patch, content, flags=re.DOTALL)

dsi_start_tag = 'dsi@ae94000 {'
dsi_idx = content.find(dsi_start_tag)
if dsi_idx != -1:
    sub_part = content[dsi_idx:dsi_idx+10000]
    
    port1_pattern = r'port@1\s*\{\s*reg\s*=\s*<0x01>;\s*endpoint\s*\{\s*\}\s*;\s*\}'
    new_port1 = """port@1 {
                                        reg = <0x01>;
                                        endpoint {
                                                phandle = <0x5555>;
                                                remote-endpoint = <0x5556>;
                                        };
                                }"""
    
    sub_part = re.sub(port1_pattern, new_port1, sub_part, count=1, flags=re.DOTALL)
    
    panel_node = """
			panel@0 {
				compatible = "samsung,sofef00";
				reg = <0x00>;
				vddio-supply = <0x56>;
				vci-supply = <0xb2>;
				poc-supply = <0xb2>;
				reset-gpios = <0x45 0x4b 0x01>;
				port {
					endpoint {
						phandle = <0x5556>;
						remote-endpoint = <0x5555>;
					};
				};
			};
"""
    if 'panel@0' not in sub_part:
        sub_part = re.sub(r'(\n\s+ports\s*\{)', panel_node + r'\1', sub_part, count=1)
    
    content = content[:dsi_idx] + sub_part + content[dsi_idx+10000:]
else:
    print("DSI not found")
    sys.exit(1)

with open(dts_path + '.patched', 'w') as f:
    f.write(content)

print("patched")
