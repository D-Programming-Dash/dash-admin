void main(string[] args) {
    import dash.api.admin_server;
    import std.conv : to;
    import std.stdio;
    import std.string : format, join;
    import std.traits;
    import thrift.codegen.client;
    import thrift.protocol.compact;
    import thrift.transport.buffered;
    import thrift.transport.socket;
    import vibecompat.data.json;

    enforce(args.length >= 2, "Usage dash-admin <command> [args ...]");

    auto socket = new TBufferedTransport(new TSocket("127.0.0.1", 3473));
    auto server = tClient!AdminServer(tCompactProtocol(socket));

    void delegate(string[])[string] commandMap;
    foreach (methodName; __traits(allMembers, AdminServer)) {
        alias MethodType = typeof(__traits(getMember, AdminServer, methodName));
        alias Args = ParameterTypeTuple!MethodType;
        commandMap[methodName] = (string[] stringArgs) {
            enforce(stringArgs.length == Args.length,
                format("Expected %s arguments for '%s%s'.", Args.length,
                    methodName, Args.stringof));

            Args args;
            foreach (i, ref arg; args) {
                alias T = typeof(arg);
                // DMD @@BUG@@: This causes an ICE due to template being leaked
                // out of the speculative to!() instantiations, so just hardcode
                // a few types we need.
                /+ static if (is(typeof(to!T(stringArgs[i])))) {
                    arg = to!T(stringArgs[i]);
                } +/
                static if (is(T : string)) {
                    arg = stringArgs[i];
                } else static if (is(T == enum)) {
                    arg = to!T(stringArgs[i]);
                } else {
                    arg = parseJson(stringArgs[i]).deserializeJson!T;
                } //else static assert(0, "Don't know how to serialize API type " ~ typeof(arg).stringof);
            }

            static if (is(ReturnType!MethodType == void)) {
                __traits(getMember, server, methodName)(args);
            } else {
                writeln(__traits(getMember, server, methodName)(args));
            }
        };
    }

    auto cmd = args[1] in commandMap;
    enforce(cmd, "Command must be one of: %s.".format(commandMap.byKey.join(", ")));

    socket.open();
    scope(exit) socket.close();
    (*cmd)(args[2 .. $]);
}
