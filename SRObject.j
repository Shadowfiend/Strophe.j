@import <Foundation/CPObject.j>

/*!
 * A base class for Strophe.j objects that require a connection to work
 * correctly.
 */
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
