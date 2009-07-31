@import "strophe.js"
@import <ObjJUtils/DelegateProxy.j>

#define SR_ERROR_STATUS                 Strophe.Status.ERROR
#define SR_CONNECTING_STATUS            Strophe.Status.CONNECTING_STATUS
#define SR_CONNECTION_FAILED_STATUS     Strophe.Status.CONNFAIL
#define SR_AUTHENTICATING_STATUS        Strophe.Status.AUTHENTICATING
#define SR_AUTHENTICATION_FAILED_STATUS Strophe.Status.AUTHFAIL
#define SR_CONNECTED_STATUS             Strophe.Status.CONNECTED
#define SR_DISCONNECTED_STATUS          Strophe.Status.DISCONNECTED
#define SR_DISCONNECTING_STATUS         Strophe.Status.DISCONNECTING

@implementation SRJabberConnection : CPObject
{
    id stropheConnection;
    CPURL boshURL;

    SRMyUser currentUser;
    BOOL loggedIn;

    id delegate;
    DelegateProxy delegateProxy;
}

- (SRJabberConnection)initWithBoshUrl:(CPURL)aURL delegate:(id)aDelegate
{
    boshURL = aURL;
    stropheConnection = new Strophe.Connection(aURL);

    delegate = aDelegate;
    delegateProxy = [DelegateProxy proxyWithDelegate:delegate];

    return self;
}

- (void)connectAs:(SRMyUser)aUser withPassword:(CPString)aPassword
{
    currentUser = aUser;

    stropheConnection.addHandler(function(stanza)
        {
            [self didReceiveStanza:stanza]

            return true;
        });
    stropheConnection.connect([currentUser JIDString], aPassword),
        function(status, error)
        {
            [self didCompleteWithStatus:status error:error]
        });
}

- (void)connectWithJID:(id)aJID withPassword:(CPString)aPassword
{
    var user = [SRMyUser userWithConnection:self JID:aJID];
    
    [self connectAs:user withPassword:aPassword]
}

- (void)didCompleteWithStatus:(CPString)aStatus
                        error:(id)anError
{
    if (aStatus == SR_ERROR_STATUS || aStatus == SR_CONNECTION_FAILED_STATUS)
        [delegateProxy connection:self didFailWithError:anError]
    else if (aStatus == SR_AUTHENTICATION_FAILED_STATUS)
        [delegateProxy connection:self didFailToAuthenticateWithError:anError]
    else if (aStatus == SR_CONNECTED_STATUS)
    {
        [delegateProxy connectionDidConnectSuccessfully:self]
        loggedIn = YES;
    }
    else if (aStatus == SR_AUTHENTICATING_STATUS)
        [delegateProxy connectionIsAuthenticating:self]
    else if (aStatus == SR_CONNECTING_STATUS)
        [delegateProxy connectionIsConnecting:self]
    else if (aStatus == SR_DISCONNECTING_STATUS)
        [delegateProxy connectionIsDisconnecting:self]
    else if (aStatus == SR_DISCONNECTED_STATUS)
        [delegateProxy connectionDidDisconnect:self]
}

- (void)didReceiveStanza:(id)aJabberStanza
{
    [delegateProxy connection:self
            didReceiveMessage:[SRMessage messageWithStanza:aJabberStanza]]
}

- (void)sendMessage:(SRMessage)aMessage
{
    [self sendStanza:[aMessage stanza]];
}

- (void)sendStanza:(id)aJabberStanza
{
    stropheConnection.send(aJabberStanza);
}

- (SRMyUser)currentUser
{
    return currentUser;
}

- (BOOL)loggedIn
{
    return loggedIn;
}

- (id)delegate
{
    return delegate;
}

@end
