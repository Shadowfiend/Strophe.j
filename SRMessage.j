@import "SRObject.j"

var SRMessageElement = 'message';

/*!
 * The SRMessage class represents a Jabber message in Strophe.j. It wraps a
 * strophe.js stanza and provides some convenience methods on it.
 *
 * In particular, it carries SRJID objects for the from and to JIDs. It also
 * provides a convenience method replyWithStanza: that takes a strophe.js stanza
 * and wraps it in an SRMessage object with the appropriate from and to JIDs.
 * When the stanza property of this new message is accessed, it is correctly set
 * up with the from and to JIDs.
 */
@implementation SRMessage : SRObject
{
    id stanza;
    SRJID toJID;
    SRJID fromJID;
}

+ (SRMessage)messageWithText:(CPString)messageText
{
    return [self messageWithStanza:$msg().c('body').t(messageText).tree()];
}

+ (SRMessage)messageFrom:(SRJID)fromJID
                      to:(SRJID)toJID
                withText:(CPString)messageText
{
    return [self messageFrom:fromJID
                          to:toJID
                  withStanza:$msg().c('body').t(messageText).tree()];
}

+ (SRMessage)messageFrom:(SRJID)fromJID
                      to:(SRJID)toJID
              withStanza:(id)aJabberStanza
{
    return [[self alloc] initWithFrom:fromJID to:toJID stanza:aJabberStanza];
}

+ (SRMessage)messageWithStanza:(id)aJabberStanza
{
    return [[self alloc] initWithStanza:aJabberStanza];
}

- (SRMesssage)initWithFrom:(SRJID)_fromJID
                        to:(SRJID)_toJID
                    stanza:(id)aJabberStanza
{
    _fromJID = fromUser;
    _toJID = toUser;
    stanza = aJabberStanza;

    if (stanza.getAttribute('_realname') == SRMessageElement)
    {
        stanza.setAttribute('from', [_fromJID JID]);
        stanza.setAttribute('to', [_toJID JID]);
    }
    else
    {
        stanza = $msg({ from: [_fromJID JID], to: [_toJID JID] }).cnode(stanza)
                                                                 .tree();
    }
}

- (SRMessage)initWithStanza:(id)aJabberStanza
{
    stanza = aJabberStanza;
    toJID = [SRJID JIDWithStringJID:aJabberStanza.getAttribute('to')];
    fromJID = [SRJID JIDWithStringJID:aJabberStanza.getAttribute('from')];

    return self;
}

- (id)stanza
{
    return stanza;
}

- (CPString)text
{
    return jQuery(stanza).text();
}

- (SRJID)toJID
{
    return toJID;
}

- (void)setToJID:(SRJID)aJID
{
    toJID = aJID;

    if (stanza && stanza.getAttribute('_realname') == SRMessageElement)
        stanza.setAttribute('to', [aJID escaped]);
}

- (SRJID)fromJID
{
    return fromJID;
}

- (void)setFromJID:(SRJID)aJID
{
    fromJID = aJID;

    if (stanza && stanza.getAttribute('_realname') == SRMessageElement)
        stanza.setAttribute('from', [aJID escaped]);
}

- (void)setType:(CPString)aMessageType
{
    stanza.setAttribute('type', aMessageType);
}

- (SRMessage)replyWithStanza:(id)aJabberStanza
{
    var msg = [SRMessage messageFrom:toJID
                                  to:fromJID
                          withStanza:aJabberStanza];
}

@end
