# Ugly test runner for handwritten assembly tests
# Use ./run_assembly fst for fst wave dump
# Use ./run_assembly.${1} for vpd wave dump
cwd="$PWD"
echo $cwd
rm sim/assembly_tests_results/ -r
mkdir sim/assembly_tests_results/

cd ../software/; 
cd assembly_btype; make clean; make; cd ../
cd assembly_jtype; make clean; make; cd ../
cd assembly_itype; make clean; make; cd ../
cd assembly_csr; make clean; make; cd ../
cd assembly_rtype; make clean; make; cd ../
cd assembly_store_and_load; make clean; make; cd ../
cd $cwd

! make clean-sim
make sim/assembly_btype_testbench.${1} > sim/assembly_tests_results/btype.log 
cat sim/assembly_tests_results/btype.log | grep FAIL -i
make sim/assembly_jtype_testbench.${1} > sim/assembly_tests_results/jtype.log
cat sim/assembly_tests_results/jtype.log | grep FAIL -i
make sim/assembly_rtype_testbench.${1} > sim/assembly_tests_results/rtype.log
cat sim/assembly_tests_results/rtype.log | grep FAIL -i
make sim/assembly_csr_testbench.${1} > sim/assembly_tests_results/csr.log
cat sim/assembly_tests_results/csr.log | grep FAIL -i
make sim/assembly_store_and_load_testbench.${1} > sim/assembly_tests_results/store_and_load.log
cat sim/assembly_tests_results/store_and_load.log | grep FAIL -i
make sim/assembly_itype_testbench.${1} > sim/assembly_tests_results/itype.log
cat sim/assembly_tests_results/itype.log | grep FAIL -i

failed=$(cat sim/assembly_tests_results/*.log | grep FAIL -i)
passed=$(cat sim/assembly_tests_results/*.log | grep PASS -i)
num_failed=$(cat sim/assembly_tests_results/*.log | grep "FAIL -" -i| wc -l)
num_passed=$(cat sim/assembly_tests_results/*.log | grep "PASS -" -i| wc -l)
num_total=$((num_failed+num_passed))

echo $failed
echo "Failed: $num_failed / $num_total"
echo "Passed: $num_passed / $num_total"
