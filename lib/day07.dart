import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';
import 'package:collection/collection.dart';

enum HandType {
  //Five of a kind, where all five cards have the same label: AAAAA
  FiveOfAKind,

  //Four of a kind, where four cards have the same label and one card has a different label: AA8AA
  FourOfAKind,

  //Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
  FullHouse,

  //Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
  ThreeOfAKind,

  //Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
  TwoPair,

  //One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
  OnePair,

  //High card, where all cards' labels are distinct: 23456
  HighCard,
}

enum CardType {
  A, K, Q, J, T, C9, C8, C7, C6, C5, C4, C3, C2
}

HandType GetHandType(List<CardType> hand) {
  var handType;

  var counts = List.generate(CardType.values.length, (index) => 0);
  for(var c in hand) {
    counts[c.index]++;
  }

  var cardsMap = <CardType, int>{};
  for(var c in hand) {
    cardsMap[c] = counts[c.index];
  }

  //FiveOfAKind
  if (cardsMap.length == 1) {
    handType = HandType.FiveOfAKind;
    return handType;
  }

  //FourOfAKind
  if (cardsMap.length == 2) {
    if(cardsMap.entries.any((element) => element.value == 4)) {
      handType = HandType.FourOfAKind;
      return handType;
    }
  }

  //FullHouse
  if(cardsMap.entries.length == 2 && cardsMap.entries.any((element) => element.value == 3)) {
    return HandType.FullHouse;
  }

  //ThreeOfAKind
  if(cardsMap.length == 3 && cardsMap.entries.any((element) => element.value == 3)) {
    return HandType.ThreeOfAKind;
  }

  //TwoPair
  if(cardsMap.length == 3 && cardsMap.entries.where((element) => element.value == 2).length == 2) {
    return HandType.TwoPair;
  }

  //OnePair
  if(cardsMap.length == 4 && cardsMap.entries.any((element) => element.value == 2)) {
    return HandType.OnePair;
  }

  //HighCard
  if(cardsMap.length == 5) {
    return HandType.HighCard;
  }

  throw Exception("Invalid hand: $hand");
}

List<CardType> UpLiftHandWithJokers(int id, List<CardType> hand) {
  List<CardType> newHand = List.generate(hand.length, (index) => hand[index]);

  var counts = List.generate(CardType.values.length, (index) => 0);
  for(var c in hand) {
    counts[c.index]++;
  }

  var cardsMap = <CardType, int>{};
  for(var c in hand) {
    cardsMap[c] = counts[c.index];
  }

  int jokers = counts[CardType.J.index];

  if (jokers == 0)
    return newHand;

  //FiveOfAKind
  if(jokers == 5) {
    for (var i = 0; i < newHand.length; ++i) {
      newHand[i] = CardType.A;
    }
    if (GetHandType(newHand) != HandType.FiveOfAKind) {
      throw Exception("Invalid hand: $newHand");
    }
    return newHand;
  }

  if(cardsMap.length == 2 && (jokers + cardsMap.entries.where((element) => element.key != CardType.J).first.value) == 5) {
    var c = cardsMap.entries.where((element) => element.key != CardType.J).first.key;
    for (var i = 0; i < newHand.length; ++i) {
      if (newHand[i] == CardType.J) {
        newHand[i] = c;
      }
    }
    if (GetHandType(newHand) != HandType.FiveOfAKind) {
      throw Exception("Invalid hand: $newHand");
    }
    return newHand;
  }

  //FourOfAKind
  // one card of type X (non - J), another 1 or more of type R different from X (non - J), and the rest are J
  if (cardsMap.length == 3
      && jokers == 3
  )
  {
    var bestCardType = cardsMap.entries.reduce(
            (curBest, card) =>
            (curBest.key == CardType.J || card.key.index < curBest.key.index && card.key != CardType.J) ? card : curBest).key;

    for (var i = 0; i < newHand.length; ++i) {
      if (newHand[i] == CardType.J) {
        newHand[i] = bestCardType;
      }
    }
    if (GetHandType(newHand) != HandType.FourOfAKind) {
      throw Exception("Invalid hand: $hand -> $newHand");
    }
    return newHand;
  }
  if (cardsMap.length == 3
    && jokers == 2
    && cardsMap.entries.any((element) => element.value == 2 && element.key != CardType.J)
  )
  {
    var cardRType = cardsMap.entries.where((element) => element.value == 2 && element.key != CardType.J).first.key;

    for (var i = 0; i < newHand.length; ++i) {
        if (newHand[i] == CardType.J) {
          newHand[i] = cardRType;
        }
      }
      if (GetHandType(newHand) != HandType.FourOfAKind) {
        throw Exception("Invalid hand: $hand -> $newHand");
      }
      return newHand;
  }
  if (cardsMap.length == 3
      && jokers == 1
      && cardsMap.entries.any((element) => element.value == 3 && element.key != CardType.J)
  )
  {
    var cardRType = cardsMap.entries.where((element) => element.value == 3 && element.key != CardType.J).first.key;

    for (var i = 0; i < newHand.length; ++i) {
      if (newHand[i] == CardType.J) {
        newHand[i] = cardRType;
      }
    }
    if (GetHandType(newHand) != HandType.FourOfAKind) {
      throw Exception("Invalid hand: $hand -> $newHand");
    }
    return newHand;
  }

  //FullHouse
  if(cardsMap.entries.length == 3 && jokers == 1) {
    var cardType1 = cardsMap.entries.where((e) => e.value == 2 && e.key != CardType.J).first.key;
    var cardType2 = cardsMap.entries.where((e) => e.value == 2 && e.key != CardType.J && e.key != cardType1).first.key;
    var betterCardType = cardType1.index < cardType2.index ? cardType1 : cardType2;
    for (var i = 0; i < newHand.length; ++i) {
      if (newHand[i] == CardType.J) {
        newHand[i] = betterCardType;
      }
    }
    if (GetHandType(newHand) != HandType.FullHouse) {
      throw Exception("Invalid hand: $newHand");
    }
    return newHand;
  }

  //ThreeOfAKind
  if(cardsMap.entries.length == 4 && jokers == 1) {
    var bestCardType = cardsMap.entries.where((e) => e.value == 2 && e.key != CardType.J).first.key;

    for (var i = 0; i < newHand.length; ++i) {
      if (newHand[i] == CardType.J) {
        newHand[i] = bestCardType;
      }
    }
    if (GetHandType(newHand) != HandType.ThreeOfAKind) {
      throw Exception("Invalid hand: $newHand");
    }
    return newHand;
  }
  if(cardsMap.entries.length == 4 && jokers == 2) {
    var bestCardType = cardsMap.entries.reduce(
            (curBest, card) => (curBest.key == CardType.J || card.key.index < curBest.key.index && card.key != CardType.J)? card : curBest).key;

    for (var i = 0; i < newHand.length; ++i) {
      if (newHand[i] == CardType.J) {
        newHand[i] = bestCardType;
      }
    }
    if (GetHandType(newHand) != HandType.ThreeOfAKind) {
      throw Exception("Invalid hand: $newHand");
    }
    return newHand;
  }

  //OnePair
  if(cardsMap.length == 5 && jokers == 1) {
    var bestCardType;
    for (var i = 0; i < counts.length; ++i) {
      if (counts[i] != 0 && i != CardType.J.index) {
        bestCardType = CardType.values[i];
        break;
      }
    }
    for (var i = 0; i < newHand.length; ++i) {
      if (newHand[i] == CardType.J) {
        newHand[i] = bestCardType;
      }
    }
    if (GetHandType(newHand) != HandType.OnePair) {
      throw Exception("Invalid hand: $newHand");
    }
    return newHand;
  }

  throw Exception("Invalid hand: $hand");
}

String ToLetters(List<CardType> hand) {
  var handStr = "";
  for (var i = 0; i < hand.length; ++i) {
    switch(hand[i]) {
      case CardType.A: handStr += 'A'; break;
      case CardType.K: handStr += 'K'; break;
      case CardType.Q: handStr += 'Q'; break;
      case CardType.J: handStr += 'J'; break;
      case CardType.T: handStr += 'T'; break;
      case CardType.C9: handStr += '9'; break;
      case CardType.C8: handStr += '8'; break;
      case CardType.C7: handStr += '7'; break;
      case CardType.C6: handStr += '6'; break;
      case CardType.C5: handStr += '5'; break;
      case CardType.C4: handStr += '4'; break;
      case CardType.C3: handStr += '3'; break;
      case CardType.C2: handStr += '2'; break;
    }
  }
  return handStr;
}

class HandData {
  List<CardType> hand = [];
  int bid = 0;
  HandType type = HandType.HighCard;

  String handStr = "";

  List<CardType> upLiftedHand = [];

  HandType upLiftedHandType = HandType.HighCard;

  @override
  String toString() {
    return 'HandData{hand: $handStr ($hand), bid: $bid, type: $type}';
  }
}

int compareListsLexicographically(List<CardType> list1, List<CardType> list2, bool part2) {
  int minLength = min(list1.length, list2.length);

  for (int i = 0; i < minLength; i++) {
    if (list1[i] != list2[i]) {
      if (part2) {
        if (list1[i] == CardType.J) {
          return 1;
        }
        if (list2[i] == CardType.J) {
          return -1;
        }
      }
      return list1[i].index.compareTo(list2[i].index);
    }
  }

  if (list1.length == list2.length) {
    return 0; // Lists are equal
  } else {
    return list1.length < list2.length ? -1 : 1; // Shorter list is considered smaller
  }
}

int compareHands(HandData hand1, HandData hand2, bool part2) {
  if (part2) {
    if (hand1.upLiftedHandType != hand2.upLiftedHandType) {
      return hand1.upLiftedHandType.index.compareTo(hand2.upLiftedHandType.index);
    }
  }
  else {
    if (hand1.type != hand2.type) {
      return hand1.type.index.compareTo(hand2.type.index);
    }
  }
  return compareListsLexicographically(hand1.hand, hand2.hand, part2);
}

@DayTag()
class Day07 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static List<HandData> parseData(var data) {
    var handData = <HandData>[];
    var rg = RegExp(r"([AKQJT23456789]{5}) ([0-9]+)");
    LineSplitter()
        .convert(data)
        .forEach((element) {
          var match = rg.firstMatch(element);
          if(match == null) {
            throw Exception("Invalid input data");
          }
          var hand = match.group(1)!;
          var bid = int.parse(match.group(2)!);
          var handDataItem = HandData();
          handDataItem.hand = hand.split('').map((e) {
            switch(e) {
              case 'A': return CardType.A;
              case 'K': return CardType.K;
              case 'Q': return CardType.Q;
              case 'J': return CardType.J;
              case 'T': return CardType.T;
              case '9': return CardType.C9;
              case '8': return CardType.C8;
              case '7': return CardType.C7;
              case '6': return CardType.C6;
              case '5': return CardType.C5;
              case '4': return CardType.C4;
              case '3': return CardType.C3;
              case '2': return CardType.C2;
              default: throw Exception("Invalid card: $e");
            }
          }).toList();
          handDataItem.upLiftedHand = UpLiftHandWithJokers(handData.length, handDataItem.hand);
          //print("#${handData.length} uplifing: ${handDataItem.hand} -> ${handDataItem.upLiftedHand}");
          handDataItem.bid = bid;
          handDataItem.handStr = hand;
          handDataItem.type = GetHandType(handDataItem.hand);
          handDataItem.upLiftedHandType = GetHandType(handDataItem.upLiftedHand);
          handData.add(handDataItem);
    });
    return handData;
  }

  int solve(List<HandData> mapData, {var part2 = false}) {
    int total = 0;

    mapData.sort((a, b) => compareHands(b, a, part2));
    for (var i = 0; i < mapData.length; ++i) {
      var hand = mapData[i];
      total += hand.bid * (i+1);
    }

   //for (var i = 0; i < mapData.length; ++i) {
   //   var hand = mapData[i];
   //   print('${hand.handStr} ${hand.type} -> ${ToLetters(hand.upLiftedHand)} ${hand.upLiftedHandType} ${hand.bid} ');
   // }

    return total;
  }

  @override
  Future<void> run() async {
    print("Day07");

    var data = readData("../adventofcode_input/2023/data/day07.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2023/data/day07_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2023/data/day07_result.txt", 1));
  }
}
