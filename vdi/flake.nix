{
  description = "VDI flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs;
        [
          virt-manager
          spice-vdagent
          spice-gtk
          usbredir
          qemu_kvm
          libvirt
        ];

        shellHook = ''
          VDI_NAME="win11"
          VDI_VIRSH_CMD="$(command -v virsh) --connect qemu:///system"
          VDI_VIRTMGR_CMD="$(command -v virt-manager) --connect qemu:///system"
          echo "Entering VDI $VDI_NAME"
          $VDI_VIRSH_CMD start $VDI_NAME
          $VDI_VIRTMGR_CMD --show-domain-console $VDI_NAME
          trap '\
            echo exiting VDI $VDI_NAME; \
            echo "Shutting down $VDI_NAME"; \
            $VDI_VIRSH_CMD shutdown $VDI_NAME
            for ((i=1; i<=5; i++)); do
              if $VDI_VIRSH_CMD list --state-running --name | grep -q $VDI_NAME; then
                echo "Domain '$VDI_NAME' is shut down."
                break
              fi
              sleep 2
            done

            CONSOLE_PID=$(pgrep -f "$VDI_NAME")
            if [ -n "$CONSOLE_PID" ]; then
              echo "Closing window for $VDI_NAME"
              kill -s 9 $CONSOLE_PID
            fi
          ' EXIT
        ''
        ;
      };
    };
}
