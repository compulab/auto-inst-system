#############################################################################
# int wait_on_pid(int pid)
#
# wait command wrapper for ATP.
# Returns wait command return value
wait_on_pid() {
        local pid=$1

        while [ -e /proc/$pid ] ; do
                echo -n "."
                sleep 1
        done

        echo ""
        wait $pid

        return $?
}

#############################################################################
# int cmd_progr(char *cmd, ...)
#
# Any command wrapper with progress indication
# Returns 0 in case of success, 1 otherwise
cmd_progr() {
        local cmd=$1
        shift;

        $cmd $* &> /dev/null & pid=$!

        wait_on_pid $pid

        return $?
}
