@echo off

echo Building Registered version ...
pushd Registered\install
call build.cmd
popd

echo Building Shareware version ...
pushd Shareware\install
call build.cmd
popd

