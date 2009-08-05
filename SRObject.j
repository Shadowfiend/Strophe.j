@import <Foundation/CPObject.j>

@implementation SRObject : CPObject
{
    SRJabberConnection connection;
}

- (SRObject)initWithConnection:(SRJabberConnection)aConnection
{
    connection = aConnection;

    return self;
}

- (SRJabberConnection)connection
{
    return connection;
}

@end
