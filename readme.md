<center><a href="https://otterkring.github.io/MainPage" style="font-size:75%;">return to MainPage</a></center>

# ConvertTo-SecurityEnabledDistributionGroup / Adding permissions to mailboxes
## Correctly create security-enabled universal distribution groups



### Why ...

I skipped this version, but from all I know Exchange 2013 introduced a requirement for _universal_ groups when creating distribution groups. Latest in Exchange 2016 you cannot longer mail-enable global groups anymore. And Exchange Online will not even show you non-universal groups anymore as a result for `Get-Group`. Oh, and you cannot nest e.g. a global group in a universal group. So I guess we better get used to the universals. :-)

In some cases you do not even intend a group to become mail-enabled, but Exchange forces you to convert it. This happens when you need to permit access to a group on folder level.

#### You need folder-level permissions when:
- you share a calendar
- you want to provide cross-premise access on calendars in a hybrid environment (on-premise user to cloud user's calendar or vize-versa) to not break permissions after a mailbox' migration
- you want to permit read-only access to a mailbox, which can only be done on folder level. Forget trying to use `Add-MailboxPermission -Access ReadPermission`. While the parameter does not raise an error, it does not work. Officially!

For additional help on mailbox read-only permissions check my repostiory on [Read-Only Mailbox Access](https://otterkring.github.io/PS_ReadOnlyMailboxAccess/)

### How to use `ConvertTo-SecurityEnabledDistributionGroup`

Lets assume you already created a global security group in Active Directory.

Start the conversion like:

`Get-Group yourgroupsname | ConvertTo-SecurityEnabledDistributionGroup`

The function will take the identity from the pipe and start the conversion along with some checks inside. You can also pass a SamAccountName for identification.

The function should take more or less any type of group you throw at it and correctly convert it to a security- and mail-enabled universal group.

#### BUT... *VERY IMPORTANT!*

If you created the group in Active Directory as a distribution group only, NOT as a security group, the conversion will fail deliberately, because from my experience Exchange 2016 will not accept a group which has been security-enabled AFTER it was created as a distribution group. It only works the other way around.




I know, it's not much of a deal to manually set these group attributes, but it saves you a couple of cmdlets a day, and even more, if you have to convert some groups in a batch.


Good luck and happy coding!
Max