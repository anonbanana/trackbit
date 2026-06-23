export 'query_executor_stub.dart'
    if (dart.library.io) 'query_executor_io.dart'
    if (dart.library.js) 'query_executor_web.dart';
