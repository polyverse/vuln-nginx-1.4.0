# DEPRECATION NOTICE

Please note that this repository has been deprecated and is no longer actively maintained by Polyverse Corporation.  It may be removed in the future, but for now remains public for the benefit of any users.

Importantly, as the repository has not been maintained, it may contain unpatched security issues and other critical issues.  Use at your own risk.

While it is not maintained, we would graciously consider any pull requests in accordance with our Individual Contributor License Agreement.  https://github.com/polyverse/contributor-license-agreement

For any other issues, please feel free to contact info@polyverse.com

---

# Vulnerable nginx 1.4.0 Docker image
## Docker Image
https://hub.docker.com/repository/docker/polyverse/vulnerable-nginx-1.4.0

## Usage
```
USAGE

    This project is of the familiar form:
        bash build.sh
        bash test.sh
        bash publish.sh

    After successful build.sh, you can run the container thus:
        docker run -it -p 80:80 --rm --name base-nginx-1.4.0-32 polyverse/vulnerable-nginx-1.4.0:base

    While it is running, it will be available on localhost thus:
         curl localhost:80

    This should display "Hello world!"

    At the same time, you can run metasploit-framework like this:

        docker run -it -p 4444:4444 --link base-nginx-1.4.0-32 metasploitframework/metasploit-framework

    Within Metasploit, you can exploit the vulnerable nginx thus:
        use exploit/linux/http/nginx_chunked_size
	set RHOSTS base-nginx-1.4.0
	set TARGET 0
        exploit

    Back on the terminal output of the vulnerable nginx server you should see stack smashing errors
    occuring as the Metasploit module brute-forces the stack canary. (TBD: The exploit still needs
    to be amended to include the locations of the gadgets as they happen to fall in base-nginx-1.4.0)


    There is also a 64 bit version made for this BROP attack: https://www.exploit-db.com/exploits/32277.
    This is the source of that exploit: http://www.scs.stanford.edu/brop (and a little bit newer).

    To try the BROP attack, start the 64 bit version thus:
        docker run -it -p 80:80 --rm --name base-nginx-1.4.0-64 507760724064.dkr.ecr.us-west-2.amazonaws.com/base-nginx-1.4.0

    Then, since you have access to the 64 nginx server on localhost:80, enter the directory BROP exploit and enter:
        ./brop.rb

    It'll grind a lot, you'll see timeout's and some other messages in the BROP windows as well as diagnostics in the BROP window.

    To run nginx using the debugger:
        # docker run --entrypoint /bin/bash --privileged -it --rm --name base-target polyverse/vulnerable-nginx-1.4.0:base
        # gdb
        gdb> start -g "daemon off;"
        gdb> continue
```
