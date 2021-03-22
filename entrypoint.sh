#!/bin/bash

cd ${APP_CODE_PATH_CONTAINER}
flutter create .
flutter run -d web-server --web-port=${WEB_SERVER_PORT} --web-hostname 0.0.0.0
#exec "$@"
