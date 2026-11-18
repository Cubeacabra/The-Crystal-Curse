// Bella's hello script.
// Demonstrates: plain narration, three branching choices, per-branch
// follow-up text, and ending the conversation.

Oh Larry it's so good to see you!
You must help us, our allies the sharks have turned on us and demolished our poor city!
You'll help us won't you? You'll go teach the sharks a lesson?

* [Of course!]
    Thank goodness! I knew I could count on you Larry! I believe you should go check on our crab friends first in their town, they should have resources to help on your journey # Mayor Lobster Success
    -> END

* [No...]
   Wait, what? Are you sure? Our village depends on you!
   ** [Okayyy]
    Thank goodness! I knew I could count on you Larry! I believe you should go check on our crab friends first in their town, they should have resources to help on your journey # Mayor Lobster Success
   -> END
   ** [No...]
   How unfortunate... I guess we're all doomed...
                Having denied his quest, the lobster village was soon decimated by the sharks who then went to conquer the world...
    -> END
