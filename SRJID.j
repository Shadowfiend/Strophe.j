@import <ObjJUtils/BlankSlate.j>

@implementation SRJID : BlankSlate
{
    CPString fullJID;
}

+ (SRJID)JIDWithStringJID:(CPString)aJID
{
    return [[self alloc] initWithStringJID:aJID];
}

- (SRJID)initWithStringJID:(CPString)aJID
{
    fullJID = aJID;

    return self;
}

- description
{
    return fullJID;
}

- node
{
    return Strophe.getNodeFromJid(fullJID);
}

- domain
{
    return Strophe.getDomainFromJid(fullJID);
}

- resource
{
    return Strophe.getResourceFromJid(fullJID);
}

- bare
{
    return Strophe.getBareJidFromJid(fullJID);
}

- escaped
{
    return Strophe.escapeJid(fullJID);
}

- unescaped
{
    return Strophe.unescapeJid(fullJID);
}

@end
