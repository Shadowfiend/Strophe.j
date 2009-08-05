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
