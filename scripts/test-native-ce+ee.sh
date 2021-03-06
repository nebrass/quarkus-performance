#!/bin/sh

# Runs the tests for the native-image executables only

DEMO_URL=http://localhost:8080/hello

# run tests
sleep 1
/work/scripts/test-single.sh "/work/demo-quarkus/target/demo-ce -Xmn8M -Xmx8M" $DEMO_URL quarkus-native-simple-ce "Quarkus (REST) via GraalVM Native Image (21.1.0 CE)"
sleep 1
/work/scripts/test-single.sh "/work/demo-quarkus/target/demo-ee -Xmn8M -Xmx8M" $DEMO_URL quarkus-native-simple-ee "Quarkus (REST) via GraalVM Native Image (21.1.0 EE)"
sleep 1
/work/scripts/test-single.sh "/work/demo-quarkus-jpa/target/demo-ce -Xmn8M -Xmx8M" $DEMO_URL quarkus-native-advanced-ce "Quarkus (REST + JPA) via GraalVM Native Image (21.1.0 CE)"
sleep 1
/work/scripts/test-single.sh "/work/demo-quarkus-jpa/target/demo-ee -Xmn8M -Xmx8M" $DEMO_URL quarkus-native-advanced-ee "Quarkus (REST + JPA) via GraalVM Native Image (21.1.0 EE)"
