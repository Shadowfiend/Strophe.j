@import <ObjJUtils/DelegateProxy.j>

// strophe.js imports
/*@import "sha1.js"
@import "md5.js"
@import "b64.js"
@import "strophe.js"*/

@import "SRMessage.j"
@import "SRMyUser.j"

SR_ERROR_STATUS                 = Strophe.Status.ERROR;
SR_CONNECTING_STATUS            = Strophe.Status.CONNECTING;
SR_CONNECTION_FAILED_STATUS     = Strophe.Status.CONNFAIL;
SR_AUTHENTICATING_STATUS        = Strophe.Status.AUTHENTICATING;
SR_AUTHENTICATION_FAILED_STATUS = Strophe.Status.AUTHFAIL;
SR_CONNECTED_STATUS             = Strophe.Status.CONNECTED;
SR_ATTACHED_STATUS              = Strophe.Status.ATTACHED;
SR_DISCONNECTED_STATUS          = Strophe.Status.DISCONNECTED;
SR_DISCONNECTING_STATUS         = Strophe.Status.DISCONNECTING;

/*!
 * The SRJabberConnection class is used to manage a Strophe.j Jabber connection.
 * This connection occurs over BOSH (XEP-0124) to a URL provided at
 * instantiation time.
 *
 * The typical lifecycle of a connection involves creating a connection via the
 * connectionWithBoshURL:delegate: method, which takes the URL at which the
 * Jabber server is listening for BOSH connections as well as a delegate object
 * that will receive notifications related to the connection (typically some
 * sort of connection controller).
 *
 * Once the connection is created, you can use the connectAs:withPassword:
 * method to actually connect to the server. This method takes an SRMyUser
 * object; if you would prefer to let the SRJabberConnection create that object
 * for you, you can instead use connectWithJID:password:. This just takes a JID
 * (as a CPString) and creates an SRMyUser object.
 *
 * Both of these will connect to the BOSH service and call various delegate
 * methods as the connection proceeds. These are:
 *  - connection:didFailWithError: for generic failures,
 *  - connection:didFailToAuthenticateWithError: for authentication failures,
 *  - connectionDidConnectSuccessfully: for successful connections,
 *  - connectionIsConnecting: as the connection is connecting,
 *  - connectionIsAuthenticating: as the connection is authenticating, and
 *  - connectionDidDisconnect: once the connection has disconnected.
 *
 * Note that you should generally not start interacting with the Jabber server
 * until after the connectionDidConnectSuccessfully: delegate method is fired.
 *
 * Once the connection has successfully connected, the
 * connection:didReceiveMessage: delegate method will be called whenever a
 * message is received. The second parameter passed to this method is an
 * SRMessage object.
 *
 * Finally, to send messages to the server, you can either create an SRMessage
 * object and send it with the sendMessage: method, or you can use the
 * strophe.js helpers to create a stanza without wrapping it in an SRMessage
 * object and send it using the sendStanza: method. Both ways are acceptable,
 * and some are simply easier in certain cases (for example, SRMessage's
 * replyWithStanza: method produces another SRMessage to reply to the target
 * SRMessage, while assembling an arbitrary message will likely be easier with
 * the strophe.js helpers).
 *
 * Because a single Jabber connection may have multiple interested parties (for
 * example, a ConnectionController for handling the connection itself, a
 * MessageController for handling incoming messages, etc), more than one
 * delegate can be added to the connection. The addDelegate: method will add a
 * delegate. All delegates can implement any of the delegate methods.
 */
@implementation SRJabberConnection : CPObject
{
    id stropheConnection;
    CPURL boshURL;

    SRMyUser currentUser;
    BOOL loggedIn;

    /*!
     * Any delegates that are interested in updates.
     */
    CPArray delegates;
}

+ (SRJabberConnection)connectionWithBoshURL:(CPURL)aURL delegate:(id)aDelegate
{
    return [[self alloc] initWithBoshURL:aURL delegate:aDelegate];
}

- (SRJabberConnection)initWithBoshURL:(CPURL)aURL delegate:(id)aDelegate
{
    boshURL = aURL;
    stropheConnection = new Strophe.Connection(aURL);

    delegates = [[DelegateProxy proxyWithDelegate:aDelegate]];

    return self;
}

- (void)connectAs:(SRMyUser)aUser withPassword:(CPString)aPassword
{
    currentUser = aUser;

    stropheConnection.addHandler(function(stanza)
        {
            try
            {
                [self didReceiveStanza:stanza]
            }
            catch(anException)
            {
                objj_exception_report(anException, "SRJabberConnection.j");
            }

            return true;
        });
    stropheConnection.connect([[currentUser JID] description], aPassword,
        function(status, error)
        {
            try
            {
                [self didCompleteWithStatus:status error:error]
            }
            catch(anException)
            {
                objj_exception_report(anException, "SRJabberConnection.j");
            }
        });
}

- (void)connectAs:(SRMyUser)aUser SID:(CPString)aSID RID:(CPString)aRID
{
    currentUser = aUser;

    stropheConnection.addHandler(function(stanza)
        {
            try
            {
                [self didReceiveStanza:stanza]
            }
            catch(anException)
            {
                objj_exception_report(anException, "SRJabberConnection.j");
            }

            return true;
        });
    stropheConnection.attach([[currentUser JID] description], aSID, aRID,
        function(status, error)
        {
            try
            {
                [self didCompleteWithStatus:status error:error]
            }
            catch(anException)
            {
                objj_exception_report(anException, "SRJabberConnection.j");
            }
        });
}

- (void)connectWithJID:(CPString)aJID password:(CPString)aPassword
{
    var user = [SRMyUser userWithJID:aJID connection:self];
    
    [self connectAs:user withPassword:aPassword];
}

- (void)connectWithJID:(CPString)aJID SID:(CPString)aSID RID:(CPString)aRID
{
    var user = [SRMyUser userWithJID:aJID connection:self];
    
    [self connectAs:user SID:aSID RID:aRID];
}

- (void)addDelegate:(id)aDelegate
{
    delegates.push([DelegateProxy proxyWithDelegate:aDelegate]);
}

- (void)didCompleteWithStatus:(CPString)aStatus
                        error:(id)anError
{
    if (aStatus == SR_ERROR_STATUS || aStatus == SR_CONNECTION_FAILED_STATUS)
    {
        [self notifyDelegates:@selector(connection:didFailWithError:)
                         with:[self, anError]]
    }
    else if (aStatus == SR_AUTHENTICATION_FAILED_STATUS)
    {
        [self notifyDelegates:@selector(connection:didFailToAuthenticateWithError:)
                         with:[self, anError]]
    }
    else if (aStatus == SR_CONNECTED_STATUS || aStatus == SR_ATTACHED_STATUS)
    {
        [self notifyDelegates:@selector(connectionDidConnectSuccessfully:)
                         with:[self]];
        loggedIn = YES;
    }
    else if (aStatus == SR_AUTHENTICATING_STATUS)
    {
        [self notifyDelegates:@selector(connectionIsAuthenticating:)
                         with:[self]];
    }
    else if (aStatus == SR_CONNECTING_STATUS)
    {
        [self notifyDelegates:@selector(connectionIsConnecting:)
                         with:[self]];
    }
    else if (aStatus == SR_DISCONNECTING_STATUS)
    {
        [self notifyDelegates:@selector(connectionIsDisconnecting:)
                         with:[self]];
    }
    else if (aStatus == SR_DISCONNECTED_STATUS)
    {
        [self notifyDelegates:@selector(connectionDidDisconnect:)
                         with:[self]];
    }
}

- (void)didReceiveStanza:(id)aJabberStanza
{
    [self notifyDelegates:@selector(connection:didReceiveMessage:)
                     with:[self, [SRMessage messageWithStanza:aJabberStanza]]]
}

- (void)notifyDelegates:(SEL)aSelector with:(CPArray)anArgumentList
{
    anArgumentList.unshift(aSelector);

    for (var i = 0; i < delegates.length; ++i)
    {
        anArgumentList.unshift(delegates[i]);

        objj_msgSend.apply(null, anArgumentList);

        anArgumentList.shift();
    }
}

- (void)sendMessage:(SRMessage)aMessage
{
    [self sendStanza:[aMessage stanza]];
}

- (void)sendStanza:(id)aJabberStanza
{
    // Make sure we've got an XML element.
    if (aJabberStanza.tree)
        aJabberStanza = aJabberStanza.tree();

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
