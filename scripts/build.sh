#!/bin/sh

# Create native-image executables with community edition and enterprise edition of GraalVM

export JABBA_HOME="$HOME/.jabba"

jabba() {
    local fd3=$(mktemp /tmp/jabba-fd3.XXXXXX)
    (JABBA_SHELL_INTEGRATION=ON $HOME/.jabba/bin/jabba "$@" 3>| ${fd3})
    local exit_code=$?
    eval $(cat ${fd3})
    rm -f ${fd3}
    return ${exit_code}
}

# demo payara simple
cd /work/demo-payara
mvn clean package payara-micro:bundle

# demo payara advanced
cd /work/demo-payara-jpa
mvn clean package payara-micro:bundle

# demo spring-boot simple
cd /work/demo-spring-boot
mvn package
mvn package -Pnative
mv /work/demo-spring-boot/target/de.harald.test.demospringboot.demospringbootapplication /work/demo-spring-boot/target/demo-ce

# demo spring-boot advanced
cd /work/demo-spring-boot-jpa
mvn package
mvn package -Pnative
mv /work/demo-spring-boot-jpa/target/de.harald.test.demospringboot.demospringbootapplication /work/demo-spring-boot-jpa/target/demo-ce

# build demo quarkus simple
cd /work/demo-quarkus
jabba use graalvm-ce@21.1.0-java11
gu list
mvn package -Pnative
mv /work/demo-quarkus/target/demo-quarkus-1.0.0-SNAPSHOT-runner /work/demo-quarkus/target/demo-ce
jabba use graalvm-ee@21.1.0-java11
gu list
mvn package -Pnative
mv /work/demo-quarkus/target/demo-quarkus-1.0.0-SNAPSHOT-runner /work/demo-quarkus/target/demo-ee

# build demo quarkus advanced
cd /work/demo-quarkus-jpa
jabba use graalvm-ce@21.1.0-java11
gu list
mvn package -Pnative
mv /work/demo-quarkus-jpa/target/demo-quarkus-jpa-1.0.0-SNAPSHOT-runner /work/demo-quarkus-jpa/target/demo-ce
jabba use graalvm-ee@21.1.0-java11
gu list
mvn package -Pnative
mv /work/demo-quarkus-jpa/target/demo-quarkus-jpa-1.0.0-SNAPSHOT-runner /work/demo-quarkus-jpa/target/demo-ee
