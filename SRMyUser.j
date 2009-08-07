@import "SRUser.j"

/*!
 * The SRMyUser class represents the user that is currently logged in to the
 * Jabber server. It provides all functionality that such a user can perform,
 * including access to a roster of `buddies' whose presence the user is
 * subscribed to.
 *
 * Note that some of the functionality that SRMyUser provides is loaded
 * asynchronously via requests to the XMPP server. As such, any of these results
 * may return RESULT_PENDING as their return value, which indicates that you
 * should wait for a time and try again. You can register yourself to be
 * notified when such a result completes by invoking the
 * whenDataAvailableFor:run: method, which takes the selector whose results are
 * pending and a function to run when the results are available. The function
 * will be invoked with the results as its parameter.
 *
 * Additionally, information can change over time. The above notification
 * mechanism will trigger every time information changes for the given data
 * source, thus allowing you to be notified in real time as, for example, buddy
 * presence information is updated.
 */
@implementation SRMyUser : SRUser
{
}

- (CPString)name
{
    return [super name];
}

@end
