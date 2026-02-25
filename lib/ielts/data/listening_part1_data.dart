import 'package:flutter/foundation.dart';

@immutable
class ListeningTestData {
  const ListeningTestData({
    required this.audioAsset,
    required this.script,
    required this.correctAnswers,
    required this.wordBank,
    required this.notes,
  });

  final String audioAsset; // Flutter asset path
  final List<ScriptSeg> script;
  final Map<int, String> correctAnswers;
  final List<String> wordBank;
  final Notes notes;
}

@immutable
class ScriptSeg {
  const ScriptSeg({
    required this.id,
    required this.start,
    required this.end,
    required this.speaker,
    required this.text,
  });

  final String id;
  final double start;
  final double end;
  final String speaker;
  final String text;
}

@immutable
class Notes {
  const Notes({
    required this.passageTitle,
    required this.instructionsTitle,
    required this.instructionsText,
    required this.boxTitle,
    required this.sections,
  });

  final String passageTitle;
  final String instructionsTitle;
  final String instructionsText;
  final String boxTitle;
  final List<NotesSection> sections;
}

@immutable
class NotesSection {
  const NotesSection({
    required this.heading,
    required this.bullets,
    required this.questions,
  });

  final String heading;
  final List<String> bullets;
  final List<NotesQuestion> questions;
}

@immutable
class NotesQuestion {
  const NotesQuestion({
    required this.no,
    required this.label,
    this.trailingText = '',
  });

  final int no;
  final String label;
  final String trailingText;
}

/// ====== MAIN MAP (Part 1 only) ======
const Map<int, ListeningTestData> listeningPart1Data = {
  1: ListeningTestData(
    audioAsset: 'assets/audio/listening_part1_restaurants.wav',
    script: _scriptTest1,
    correctAnswers: _correctAnswersTest1,
    wordBank: _wordBankTest1,
    notes: _notesTest1,
  ),
  2: ListeningTestData(
    audioAsset: 'assets/audio/listening_part1_train_booking.wav',
    script: _scriptTest2,
    correctAnswers: _correctAnswersTest2,
    wordBank: _wordBankTest2,
    notes: _notesTest2,
  ),
  3: ListeningTestData(
    audioAsset: 'assets/audio/listening_part1_flat_rental.wav',
    script: _scriptTest3,
    correctAnswers: _correctAnswersTest3,
    wordBank: _wordBankTest3,
    notes: _notesTest3,
  ),
};

/// ===================================================================
/// TEST 1 – Restaurants
/// ===================================================================
const List<ScriptSeg> _scriptTest1 = [
  ScriptSeg(
    id: 'p1',
    start: 0,
    end: 20,
    speaker: 'ANNOUNCER',
    text:
        'Part 1. You will hear a woman asking a friend for restaurant '
        'recommendations. First, you have some time to look at questions 1 to 4. '
        'Now listen carefully and answer questions 1 to 4.',
  ),
  ScriptSeg(
    id: 'p2',
    start: 20,
    end: 190,
    speaker: 'DIALOGUE',
    text:
        "WOMAN: I've been meaning to ask you for some advice about restaurants. I need to book "
        "somewhere to celebrate my sister's 30th birthday, and I like the sound of that place you "
        "went to for your mum's 50th.\n\n"
        "MAN: The Junction? Yeah, I'd definitely recommend that for a special occasion. We had a "
        "great time there. Everyone really enjoyed it.\n\n"
        "WOMAN: Where is it again? I can't remember.\n\n"
        "MAN: It's on Greyson Street, only about a 2-minute walk from the station.\n\n"
        "WOMAN: Oh, that's good. I'd prefer not to have to drive anywhere, but I don't want to have "
        "to walk too far either.\n\n"
        "MAN: Yes, the location is perfect, but that's not necessarily why I'd recommend it. "
        "The food's amazing. If you like fish, it's probably the best restaurant in town for that. "
        "It's always really fresh, and there are lots of interesting dishes to choose from, but all "
        "the food is good there.\n\n"
        "WOMAN: Is it really expensive?\n\n"
        "MAN: It's certainly not cheap, but for a special occasion, I think it's fine. It's got a "
        "great atmosphere. And before dinner, you can go up on the roof and have a drink. It's "
        "really nice up there, but you need to book. It's very popular, as the views are spectacular.\n\n"
        "WOMAN: Hmm, sounds good. So that's definitely a possibility then. Is there anywhere else you "
        "can think of?\n\n"
        "MAN: If you want somewhere a bit less formal then you could try Paloma.\n\n"
        "WOMAN: Where's that? I haven't heard of it.\n\n"
        "MAN: No, it's quite new. It's only been open a few months, but it's got a great reputation "
        "already. It's in a really beautiful old building on Bow Street.\n\n"
        "WOMAN: Oh, I think I know where you mean. Right beside the cinema.\n\n"
        "MAN: Yes, that's it. I've only been there a couple of times, but I was really impressed. "
        "The chef used to work at Don Filipe's apparently. I was really sorry when that closed down.\n\n"
        "WOMAN: So is all the food they serve Spanish then?\n\n"
        "MAN: Yeah, you can get lots of small dishes to share, which always works really well if "
        "you're in a group.\n\n"
        "WOMAN: Hmm. Worth thinking about.\n\n"
        "MAN: Yeah, there's a lively atmosphere, and the waiters are really friendly. The only thing "
        "is that you need to pay a 50-pound deposit to book a table.\n\n"
        "WOMAN: A lot of restaurants are doing that these days. I should have a look at the menu to "
        "check there's a good choice of vegetarian dishes. A couple of my friends have stopped "
        "eating meat.\n\n"
        "MAN: Not sure, I'd say the selection of those would be quite limited.",
  ),
  ScriptSeg(
    id: 'p3',
    start: 190,
    end: 380,
    speaker: 'ANNOUNCER + DIALOGUE',
    text:
        'ANNOUNCER: Before you hear the rest of the conversation, you have some time to look at '
        'questions 5 to 10. Now listen and answer questions 5 to 10.\n\n'
        "MAN: I've just thought of another idea. Have you been to the Audley?\n\n"
        "WOMAN: No, don't think I've heard of it. How's it spelt?\n\n"
        "MAN: A-U-D-L-E-Y. You must have heard of it. There's been a lot about it in the press.\n\n"
        "WOMAN: I don't tend to pay much attention to that kind of thing. So where is it exactly?\n\n"
        "MAN: It's in that hotel near Baxter Bridge, on the top floor.\n\n"
        "WOMAN: Oh, the views would be incredible from up there.\n\n"
        "MAN: Yeah, I'd love to go. I can't think of the chef's name, but she was a judge on that TV "
        "cookery show recently, and she's written a couple of cookery books.\n\n"
        "WOMAN: Oh, Angela Frayn.\n\n"
        "MAN: That's the one. Anyway, it's had excellent reviews from all the newspapers.\n\n"
        "WOMAN: That would be a memorable place for a celebration.\n\n"
        "MAN: Definitely, obviously it's worth going there just for the view, but the food is supposed "
        "to be really special.\n\n"
        "WOMAN: She only likes cooking with local products, doesn't she?\n\n"
        "MAN: Yes. Everything at the restaurant has to be sourced within a short distance, and "
        "absolutely nothing flown in from abroad.\n\n"
        "WOMAN: I imagine it's really expensive though.\n\n"
        "MAN: Well, you could go for the set lunch. That's quite reasonable for a top-class restaurant, "
        "thirty pounds a head. In the evening, I think it would be more like fifty.\n\n"
        "WOMAN: At least that I should think, but I'm sure everyone would enjoy it. It's not the kind "
        "of place you leave feeling hungry though, is it? With tiny portions.\n\n"
        "MAN: No, the reviews I've read didn't mention that. I imagine they'd be average.\n\n"
        "WOMAN: Well, that's all great. Thanks...\n\n"
        'ANNOUNCER: That is the end of Part 1. You now have one minute to check your answers to Part 1.',
  ),
];

const Map<int, String> _correctAnswersTest1 = {
  1: 'fish',
  2: 'roof',
  3: 'small dishes to share',
  4: 'vegetarian dishes',
  5: 'audley',
  6: 'top floor',
  7: 'excellent reviews',
  8: 'local products',
  9: '30',
  10: 'average',
};

const List<String> _wordBankTest1 = [
  'fish',
  'roof',
  'small dishes to share',
  'vegetarian dishes',
  'Audley',
  'top floor',
  'excellent reviews',
  'local products',
  '30',
  'average',
  'meat',
  'cinema',
  'Bow Street',
  'Greyson Street',
  'deposit',
  'Spanish',
  'rooftop bar',
  'hotel',
  '50',
  'set menu',
];

const Notes _notesTest1 = Notes(
  passageTitle: 'Restaurant Recommendations for a Celebration',
  instructionsTitle: 'Questions 1–10',
  instructionsText:
      'Complete the notes below.\nWrite ONE WORD AND/OR A NUMBER for each answer.',
  boxTitle: 'CHOOSING A RESTAURANT FOR A 30TH BIRTHDAY',
  sections: [
    NotesSection(
      heading: 'THE JUNCTION',
      bullets: ['Location: on Greyson Street, a short walk from the station.'],
      questions: [
        NotesQuestion(
          no: 1,
          label: 'Best for:',
          trailingText: '(type of food, especially good there)',
        ),
        NotesQuestion(
          no: 2,
          label: 'Before dinner, customers can have a drink on the',
          trailingText: '.',
        ),
      ],
    ),
    NotesSection(
      heading: 'PALOMA',
      bullets: [
        'In a beautiful old building on Bow Street, next to the cinema.',
        'Less formal atmosphere; friendly staff.',
      ],
      questions: [
        NotesQuestion(
          no: 3,
          label: 'Type of dishes:',
          trailingText: '(good for groups)',
        ),
        NotesQuestion(
          no: 4,
          label: 'Main disadvantage:',
          trailingText: 'are quite limited.',
        ),
      ],
    ),
    NotesSection(
      heading: 'THE AUDLEY',
      bullets: ['Location: in hotel near Baxter Bridge; excellent views.'],
      questions: [
        NotesQuestion(no: 5, label: 'Name (spelling):'),
        NotesQuestion(no: 6, label: 'Location in hotel near Baxter Bridge: on the'),
        NotesQuestion(
          no: 7,
          label: 'Reputation:',
          trailingText: 'from all the newspapers.',
        ),
        NotesQuestion(
          no: 8,
          label: 'Policy: only uses',
          trailingText: '(nothing flown in from abroad).',
        ),
        NotesQuestion(no: 9, label: 'Set lunch price (£ per person):'),
        NotesQuestion(no: 10, label: 'Portion size described as:'),
      ],
    ),
  ],
);

/// ===================================================================
/// TEST 2 – Train Ticket Call
/// ===================================================================
const List<ScriptSeg> _scriptTest2 = [
  ScriptSeg(
    id: 'p1',
    start: 0,
    end: 20,
    speaker: 'ANNOUNCER',
    text:
        'Part 1. You will hear a man calling a railway company to book a train ticket. '
        'First, you have some time to look at questions 1 to 4. '
        'Now listen carefully and answer questions 1 to 4.',
  ),
  ScriptSeg(
    id: 'p2',
    start: 20,
    end: 190,
    speaker: 'DIALOGUE',
    text:
        'AGENT: Good afternoon, Eastline Rail bookings. How can I help you?\n\n'
        "MAN: Hello. I'd like to book a ticket for this weekend, please.\n\n"
        'AGENT: Certainly. Which day would you like to travel?\n\n'
        'MAN: On Friday, if possible. I need to arrive in Brighton before midday.\n\n'
        "AGENT: Right, let me check. There's a fast train that leaves at 9:10 and gets there just before 11.\n\n"
        'MAN: That sounds perfect. Is it a direct train, or do I need to change?\n\n'
        "AGENT: It's direct, so you won't have to change at all.\n\n"
        "MAN: Good. I'd like a return ticket, please. I'll be coming back on Sunday evening.\n\n"
        'AGENT: No problem. The last train back on Sunday leaves Brighton at 19:45.\n\n'
        "MAN: OK, I'll take that. Is there a quiet carriage on the Friday morning train?\n\n"
        'AGENT: Yes, carriage C is the quiet carriage.\n\n'
        "MAN: Great. I'd prefer to sit there so I can do some work on the way.",
  ),
  ScriptSeg(
    id: 'p3',
    start: 190,
    end: 380,
    speaker: 'ANNOUNCER + DIALOGUE',
    text:
        'ANNOUNCER: Before you hear the rest of the conversation, you have some time to look at '
        'questions 5 to 10. Now listen and answer questions 5 to 10.\n\n'
        'AGENT: Do you have any seating preference? For example, a window or an aisle seat?\n\n'
        'MAN: A window seat, if possible. I like to look outside while I\'m travelling.\n\n'
        "AGENT: OK, I'll reserve a window seat for you in carriage C. How would you like to pay?\n\n"
        'MAN: Can I pay by credit card over the phone?\n\n'
        'AGENT: Yes, that\'s fine. I just need the card number and expiry date.\n\n'
        "MAN: Sure, I'll give you those in a moment. Will I receive a paper ticket in the post?\n\n"
        "AGENT: We don't post tickets anymore. Instead, you'll receive an e-ticket by email.\n\n"
        'MAN: And do I need to print it out?\n\n'
        'AGENT: No, you can either print it or just show it on your phone when you board the train.\n\n'
        'MAN: Great. One last question: which platform does the train usually leave from?\n\n'
        'AGENT: It normally departs from platform 3, but please check the information screens on the day of travel.\n\n'
        'MAN: OK, thank you very much for your help.\n\n'
        "AGENT: You're welcome. Have a good trip.\n\n"
        'ANNOUNCER: That is the end of Part 1. You now have one minute to check your answers to Part 1.',
  ),
];

const Map<int, String> _correctAnswersTest2 = {
  1: 'friday',
  2: 'before midday',
  3: 'direct',
  4: 'return ticket',
  5: 'quiet carriage',
  6: 'carriage c',
  7: 'window seat',
  8: 'credit card',
  9: 'email',
  10: 'platform 3',
};

const List<String> _wordBankTest2 = [
  'Friday',
  'before midday',
  'direct',
  'return ticket',
  'quiet carriage',
  'carriage C',
  'window seat',
  'credit card',
  'email',
  'platform 3',
  'Sunday',
  '19:45',
  'Brighton',
  'aisle seat',
  'paper ticket',
  'information screens',
  'change trains',
  'single ticket',
  'platform 1',
  'morning',
];

const Notes _notesTest2 = Notes(
  passageTitle: 'Booking a Train Journey',
  instructionsTitle: 'Questions 1–10',
  instructionsText:
      'Complete the notes below.\nWrite ONE WORD AND/OR A NUMBER for each answer.',
  boxTitle: 'TRAIN JOURNEY TO BRIGHTON',
  sections: [
    NotesSection(
      heading: 'OUTWARD JOURNEY',
      bullets: ['Destination: Brighton; needs to arrive before midday.'],
      questions: [
        NotesQuestion(no: 1, label: 'Day of travel:'),
        NotesQuestion(no: 2, label: 'Must arrive:', trailingText: '(time of day)'),
        NotesQuestion(no: 3, label: 'Type of train:', trailingText: '(no changes)'),
        NotesQuestion(no: 4, label: 'Ticket type:'),
      ],
    ),
    NotesSection(
      heading: 'SEATING AND PAYMENT',
      bullets: ['Quiet carriage available on Friday morning train.'],
      questions: [
        NotesQuestion(no: 5, label: 'Prefers to sit in the', trailingText: 'carriage.'),
        NotesQuestion(no: 6, label: 'Seat reserved in', trailingText: '.'),
        NotesQuestion(no: 7, label: 'Seat preference:'),
        NotesQuestion(no: 8, label: 'Pays by:'),
      ],
    ),
    NotesSection(
      heading: 'TICKETS AND DEPARTURE',
      bullets: [
        'Receives an e-ticket instead of a paper ticket.',
        'Can show ticket on phone when boarding.',
      ],
      questions: [
        NotesQuestion(no: 9, label: 'Ticket sent by:'),
        NotesQuestion(no: 10, label: 'Train usually departs from:'),
      ],
    ),
  ],
);

/// ===================================================================
/// TEST 3 – Flat Rental Enquiry
/// ===================================================================
const List<ScriptSeg> _scriptTest3 = [
  ScriptSeg(
    id: 'p1',
    start: 0,
    end: 20,
    speaker: 'ANNOUNCER',
    text:
        'Part 1. You will hear a woman phoning about an advertisement for a flat to rent. '
        'First, you have some time to look at questions 1 to 4. '
        'Now listen carefully and answer questions 1 to 4.',
  ),
  ScriptSeg(
    id: 'p2',
    start: 20,
    end: 190,
    speaker: 'DIALOGUE',
    text:
        'LANDLORD: Hello, Green Street Rentals.\n\n'
        "WOMAN: Hi, I'm calling about the one-bedroom flat you advertised online.\n\n"
        "LANDLORD: Yes, that's right. What would you like to know?\n\n"
        'WOMAN: First, which floor is the flat on?\n\n'
        "LANDLORD: It's on the second floor of the building.\n\n"
        'WOMAN: Is there a lift, or just stairs?\n\n'
        "LANDLORD: There's no lift, I'm afraid, only stairs.\n\n"
        'WOMAN: OK. Does the flat have a balcony?\n\n'
        'LANDLORD: Yes, there is a small balcony off the living room.\n\n'
        'WOMAN: That sounds nice. Is the flat furnished, or would I need to bring my own furniture?\n\n'
        "LANDLORD: It's fully furnished, including a sofa, bed, table and chairs.\n\n"
        'WOMAN: Great. And how much is the monthly rent?\n\n'
        'LANDLORD: The rent is six hundred and fifty pounds per month.',
  ),
  ScriptSeg(
    id: 'p3',
    start: 190,
    end: 380,
    speaker: 'ANNOUNCER + DIALOGUE',
    text:
        'ANNOUNCER: Before you hear the rest of the conversation, you have some time to look at '
        'questions 5 to 10. Now listen and answer questions 5 to 10.\n\n'
        'WOMAN: Do I need to pay a deposit as well?\n\n'
        "LANDLORD: Yes, there's a deposit equal to one month's rent, which you get back at the end of the tenancy if everything is in good condition.\n\n"
        'WOMAN: I see. How long is the minimum contract?\n\n'
        'LANDLORD: The minimum is six months, but many tenants stay for a year or more.\n\n'
        "WOMAN: What's the neighbourhood like? Is it a noisy area?\n\n"
        "LANDLORD: It's actually quite a quiet street, but you're still close to the main road.\n\n"
        'WOMAN: Are there any shops nearby?\n\n'
        "LANDLORD: Yes, there's a supermarket just around the corner and a bus stop at the end of the street.\n\n"
        'WOMAN: Does the rent include any bills, like water or internet?\n\n'
        "LANDLORD: Water is included, but you'll need to arrange your own internet and electricity.\n\n"
        "WOMAN: OK, thanks. I'd like to come and see the flat. When would be a good time?\n\n"
        "LANDLORD: I'm free most evenings after six o'clock. We could arrange a viewing for tomorrow if that suits you.\n\n"
        'WOMAN: That would be perfect. Thank you very much.\n\n'
        "LANDLORD: You're welcome. See you tomorrow.\n\n"
        'ANNOUNCER: That is the end of Part 1. You now have one minute to check your answers to Part 1.',
  ),
];

const Map<int, String> _correctAnswersTest3 = {
  1: 'second floor',
  2: 'stairs',
  3: 'balcony',
  4: 'furnished',
  5: '650',
  6: 'deposit',
  7: 'six months',
  8: 'quiet street',
  9: 'supermarket',
  10: 'water',
};

const List<String> _wordBankTest3 = [
  'second floor',
  'stairs',
  'balcony',
  'furnished',
  '650',
  'deposit',
  'six months',
  'quiet street',
  'supermarket',
  'water',
  'lift',
  'unfurnished',
  'electricity',
  'internet',
  'bus stop',
  'main road',
  'one year',
  'ground floor',
  'sofa',
  'viewing',
];

const Notes _notesTest3 = Notes(
  passageTitle: 'Enquiring About a Flat to Rent',
  instructionsTitle: 'Questions 1–10',
  instructionsText:
      'Complete the notes below.\nWrite ONE WORD AND/OR A NUMBER for each answer.',
  boxTitle: 'ONE-BEDROOM FLAT ON GREEN STREET',
  sections: [
    NotesSection(
      heading: 'FLAT DETAILS',
      bullets: [
        'One-bedroom flat in a small building.',
        'Includes sofa, bed, table and chairs.',
      ],
      questions: [
        NotesQuestion(no: 1, label: 'Which floor :'),
        NotesQuestion(no: 2, label: 'Building access: only', trailingText: '(no lift).'),
        NotesQuestion(no: 3, label: 'Outside space:', trailingText: 'off the living room.'),
        NotesQuestion(no: 4, label: 'Flat is fully:'),
      ],
    ),
    NotesSection(
      heading: 'COSTS',
      bullets: ['Deposit returned if flat is in good condition.'],
      questions: [
        NotesQuestion(no: 5, label: 'Monthly rent (£):'),
        NotesQuestion(no: 6, label: "Extra payment equal to one month's rent:"),
        NotesQuestion(no: 7, label: 'Minimum contract length:'),
      ],
    ),
    NotesSection(
      heading: 'AREA AND BILLS',
      bullets: [
        'Close to main road, but street itself is fairly quiet.',
        'Shops and public transport nearby.',
      ],
      questions: [
        NotesQuestion(no: 8, label: 'Street described as a:'),
        NotesQuestion(no: 9, label: 'Nearby facility: has a', trailingText: 'just around the corner.'),
        NotesQuestion(no: 10, label: 'Bill included in the rent:'),
      ],
    ),
  ],
);
