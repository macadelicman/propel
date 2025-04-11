require 'shopify_api'
require 'graphql'
require 'graphql-client'
require 'graphql/client/http'

# query {
#   collections(first: 250) {
#     edges {
#       node {
#         id
#         title
#         handle
#         updatedAt
#         sortOrder
#       }
#     }
#   }
# }

=begin
RESPONSE:
{
  "data": {
    "collections": {
      "edges": [
        {
          "node": {
            "id": "gid://shopify/Collection/387489726711",
            "title": "Hats",
            "handle": "hats",
            "updatedAt": "2025-03-04T16:04:09Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387489759479",
            "title": "Shirts",
            "handle": "shirts",
            "updatedAt": "2025-03-04T16:04:09Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387583148279",
            "title": "Jackets & Sweatshirts",
            "handle": "jackets-sweatshirts",
            "updatedAt": "2025-03-04T16:04:09Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387583181047",
            "title": "Art1",
            "handle": "art",
            "updatedAt": "2025-03-04T16:04:09Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387583213815",
            "title": "Men's Accessories",
            "handle": "accessories",
            "updatedAt": "2025-03-04T16:04:10Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387583246583",
            "title": "Stickers & Patches",
            "handle": "stickers-patches",
            "updatedAt": "2025-03-04T16:04:10Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387583279351",
            "title": "Drinkware",
            "handle": "drinkware",
            "updatedAt": "2025-03-04T16:04:11Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387583312119",
            "title": "Miscellaneous",
            "handle": "miscellaneous",
            "updatedAt": "2025-03-04T16:04:11Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387583639799",
            "title": "All",
            "handle": "all",
            "updatedAt": "2025-03-08T19:20:56Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/387583705335",
            "title": "SHOP ALL",
            "handle": "shop-all",
            "updatedAt": "2025-03-04T16:04:13Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/388480598263",
            "title": "Branded Merch",
            "handle": "branded-merch-1-0",
            "updatedAt": "2025-03-04T16:04:13Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389341610231",
            "title": "Apparel",
            "handle": "apparel",
            "updatedAt": "2025-03-04T16:04:13Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389341642999",
            "title": "Home",
            "handle": "home",
            "updatedAt": "2025-03-07T20:37:14Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389341675767",
            "title": "Books & Games",
            "handle": "occasions",
            "updatedAt": "2025-03-08T19:20:56Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389341708535",
            "title": "Jewelry",
            "handle": "jewelry",
            "updatedAt": "2025-03-04T16:04:15Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389341806839",
            "title": "Books",
            "handle": "books",
            "updatedAt": "2025-03-07T20:40:54Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389341839607",
            "title": "Games",
            "handle": "games",
            "updatedAt": "2025-03-04T16:04:16Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389342036215",
            "title": "Collections",
            "handle": "collections",
            "updatedAt": "2025-03-04T16:04:16Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389342101751",
            "title": "Accessories",
            "handle": "accessories-1",
            "updatedAt": "2025-03-04T16:04:17Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/389342134519",
            "title": "Members Only",
            "handle": "members-only",
            "updatedAt": "2025-03-04T16:04:18Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390143901943",
            "title": "Featured Products",
            "handle": "featured-products",
            "updatedAt": "2025-03-04T16:04:18Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390389760247",
            "title": "Men's Apparel",
            "handle": "fashion-men-apparel",
            "updatedAt": "2025-03-04T16:04:19Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390389956855",
            "title": "Thnk:Men's",
            "handle": "fashion-men-thnk-branded",
            "updatedAt": "2025-03-04T16:04:19Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390390186231",
            "title": "Home Accents",
            "handle": "home-indoor-home-accents",
            "updatedAt": "2025-03-07T20:40:56Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390390513911",
            "title": "fashion-women-apparel",
            "handle": "fashion-women-apparel",
            "updatedAt": "2025-03-08T16:34:24Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390390776055",
            "title": "Thnk: Merch",
            "handle": "fashion-women-thnk-branded",
            "updatedAt": "2025-03-04T16:04:20Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391005431",
            "title": "fashion-women-outerwear",
            "handle": "fashion-women-outerwear",
            "updatedAt": "2025-03-04T16:04:21Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391070967",
            "title": "Kid's Apparel",
            "handle": "fashion-kids-apparel",
            "updatedAt": "2025-03-04T16:04:21Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391267575",
            "title": "Earrings",
            "handle": "fashion-jewelry-earrings",
            "updatedAt": "2025-03-07T20:40:25Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391300343",
            "title": "Bags and Totes",
            "handle": "fashion-accessories-bags-totes",
            "updatedAt": "2025-03-04T16:04:21Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391333111",
            "title": "Wallets",
            "handle": "fashion-accessories-walllets",
            "updatedAt": "2025-03-04T16:04:22Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391365879",
            "title": "Thnk: Accessories",
            "handle": "fashion-accessories-thnk-branded",
            "updatedAt": "2025-03-04T16:04:22Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391398647",
            "title": "Kitchen",
            "handle": "home-indoor-kitchen-table-top",
            "updatedAt": "2025-03-04T16:37:05Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391431415",
            "title": "Prints",
            "handle": "home-indoor-art",
            "updatedAt": "2025-03-04T16:04:22Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391496951",
            "title": "Furniture",
            "handle": "home-indoor-furniture",
            "updatedAt": "2025-03-04T16:04:22Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391529719",
            "title": "Pets",
            "handle": "home-indoor-pets",
            "updatedAt": "2025-03-05T18:51:06Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391595255",
            "title": "Outdoor Garden",
            "handle": "home-outdoor-garden",
            "updatedAt": "2025-03-04T16:04:23Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391660791",
            "title": "home-treasures-decorative-objects",
            "handle": "home-treasures-decorative-objects",
            "updatedAt": "2025-03-04T16:04:23Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391759095",
            "title": "Spiritual Wellness",
            "handle": "health-wellness-spriritual",
            "updatedAt": "2025-03-04T16:04:23Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391824631",
            "title": "Physical Wellness",
            "handle": "health-wellness-physical",
            "updatedAt": "2025-03-04T16:04:23Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391890167",
            "title": "Emotional Wellness",
            "handle": "health-wellness-emotional",
            "updatedAt": "2025-03-06T21:03:12Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390391955703",
            "title": "Social Wellness",
            "handle": "health-wellness-social",
            "updatedAt": "2025-03-04T16:04:23Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392021239",
            "title": "Intellectual Wellness",
            "handle": "health-wellness-intellectual",
            "updatedAt": "2025-03-04T16:04:24Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392086775",
            "title": "Vocational Wellness",
            "handle": "health-wellness-vocational",
            "updatedAt": "2025-03-04T16:04:24Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392119543",
            "title": "Financial Wellness",
            "handle": "health-wellness-financial",
            "updatedAt": "2025-03-04T16:04:24Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392152311",
            "title": "Environmental Wellness",
            "handle": "health-wellness-environmental",
            "updatedAt": "2025-03-04T16:04:24Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392217847",
            "title": "Skincare",
            "handle": "health-apothecary-skincare",
            "updatedAt": "2025-03-07T20:24:41Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392283383",
            "title": "Supplements & Herbs",
            "handle": "health-apothecary-supplements-herbs",
            "updatedAt": "2025-03-04T16:04:24Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392348919",
            "title": "Fragrances",
            "handle": "health-apothecary-aromatics",
            "updatedAt": "2025-03-07T20:37:14Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392381687",
            "title": "Self-Help",
            "handle": "occasions-reading-self-help",
            "updatedAt": "2025-03-04T16:04:24Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392512759",
            "title": "Inspiration",
            "handle": "occasions-reading-wisdom-inspiration",
            "updatedAt": "2025-03-07T17:18:47Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392611063",
            "title": "Journals & Keepsakes",
            "handle": "occasions-reading-journals-keepsakes",
            "updatedAt": "2025-03-04T16:04:24Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392774903",
            "title": "Family Games",
            "handle": "occasions-games-family",
            "updatedAt": "2025-03-04T16:04:25Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392807671",
            "title": "Activities",
            "handle": "occasions-game-adults",
            "updatedAt": "2025-03-08T19:20:56Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390392938743",
            "title": "Holiday",
            "handle": "occasions-holiday-holiday",
            "updatedAt": "2025-03-04T16:04:25Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390393069815",
            "title": "Intimacy Toys",
            "handle": "members-only-intamacy-toys",
            "updatedAt": "2025-03-04T16:04:25Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390393102583",
            "title": "Intimacy Oils",
            "handle": "members-only-intimacy-oils",
            "updatedAt": "2025-03-04T16:04:25Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390393168119",
            "title": "CBD Edibles",
            "handle": "members-only-cbd-edibles",
            "updatedAt": "2025-03-04T16:04:25Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390393233655",
            "title": "CBD Drinks",
            "handle": "members-only-cbd-drinks",
            "updatedAt": "2025-03-04T16:04:25Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390393331959",
            "title": "CBD Topicals",
            "handle": "members-only-cbd-topical-body",
            "updatedAt": "2025-03-04T16:04:25Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390393397495",
            "title": "CBD for Pets",
            "handle": "members-only-cbd-pets",
            "updatedAt": "2025-03-04T16:04:26Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390462374135",
            "title": "Physical",
            "handle": "physical",
            "updatedAt": "2025-03-04T16:04:26Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390906839287",
            "title": "Necklaces",
            "handle": "necklace",
            "updatedAt": "2025-03-04T16:04:26Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390906904823",
            "title": "Kitchen and Tabletops",
            "handle": "kitchen-and-tabletops",
            "updatedAt": "2025-03-04T16:04:26Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390907068663",
            "title": "Home Accents",
            "handle": "home-accents",
            "updatedAt": "2025-03-07T20:40:56Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390921715959",
            "title": "Thnk:Branded Accessories",
            "handle": "fashion-accessories-thnk-branded-1",
            "updatedAt": "2025-03-04T16:04:26Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390922076407",
            "title": "Women's Apparel",
            "handle": "womens-apparel",
            "updatedAt": "2025-03-08T16:34:24Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390922535159",
            "title": "Tech",
            "handle": "tech",
            "updatedAt": "2025-03-04T16:04:26Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390927155447",
            "title": "Mind, Body, Spirit",
            "handle": "bath-body-1",
            "updatedAt": "2025-03-07T20:43:27Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390962086135",
            "title": "Toys / Treats",
            "handle": "toys-treats",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390962643191",
            "title": "8  Dimensions",
            "handle": "8-dimensions",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390962839799",
            "title": "Women's Accessories",
            "handle": "womens-accessories",
            "updatedAt": "2025-03-07T20:05:51Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390963429623",
            "title": "Health",
            "handle": "health",
            "updatedAt": "2025-03-05T19:17:55Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/390963495159",
            "title": "Fitness",
            "handle": "fitness",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391006683383",
            "title": "Journals / Keepsakes",
            "handle": "journals-keepsakes",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391006716151",
            "title": "Art",
            "handle": "art-1",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391009370359",
            "title": "Children",
            "handle": "children",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391009894647",
            "title": "Kids",
            "handle": "kids",
            "updatedAt": "2025-03-07T20:40:59Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391544275191",
            "title": "Botanical",
            "handle": "botanical",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391575306487",
            "title": "Impressionist",
            "handle": "impressionist",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391575699703",
            "title": "Flower Heads",
            "handle": "flower-heads",
            "updatedAt": "2025-03-04T16:04:27Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391575798007",
            "title": "Sports Legends",
            "handle": "sports-legends",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391599456503",
            "title": "Portraits",
            "handle": "portraits",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391601717495",
            "title": "Carnival",
            "handle": "carnival",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391601750263",
            "title": "Collage",
            "handle": "collage",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391601783031",
            "title": "Fantasy",
            "handle": "fantasy",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391601815799",
            "title": "Photography",
            "handle": "photography",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391601848567",
            "title": "Anatomy Love",
            "handle": "anatomy-love",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391601881335",
            "title": "Bird Heads",
            "handle": "bird-heads",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391601914103",
            "title": "Humor",
            "handle": "humour",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391601979639",
            "title": "Miscellaneous Art",
            "handle": "miscellaneous-1",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391602012407",
            "title": "Mythical Creatures",
            "handle": "mythical-creatures",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391602045175",
            "title": "We Are Not Alone",
            "handle": "we-are-not-alone",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391602077943",
            "title": "Prehistoric",
            "handle": "prehistoric",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391602110711",
            "title": "War Clowns",
            "handle": "war-clowns",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391602143479",
            "title": "Stranger Things",
            "handle": "stranger-things",
            "updatedAt": "2025-03-04T16:04:28Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/391603552503",
            "title": "8 Dimensions",
            "handle": "8-dimensions-1",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/393291071735",
            "title": "Field Of Dreams",
            "handle": "field-of-dreams-1",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/393291104503",
            "title": "Myths & Tall Tales",
            "handle": "myths-tall-tales",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/393291137271",
            "title": "Pot Head",
            "handle": "pot-head",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/393291170039",
            "title": "Birds",
            "handle": "birds",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/393330491639",
            "title": "Occasions",
            "handle": "occasions-1",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/393330557175",
            "title": "Greeting Cards",
            "handle": "greeting-cards",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/393330589943",
            "title": "Holidays",
            "handle": "holidays",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/393330622711",
            "title": "Wrapping Paper",
            "handle": "wrapping-paper",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/400383017207",
            "title": "Vocational Well-Being",
            "handle": "vocational-well-being",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/400383836407",
            "title": "Emotional Well-Being",
            "handle": "emotional-well-being",
            "updatedAt": "2025-03-06T16:55:23Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/400383934711",
            "title": "Spiritual Well-Being",
            "handle": "spiritual-well-being",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/400384098551",
            "title": "Physical Well-Being",
            "handle": "physical-well-being",
            "updatedAt": "2025-03-04T16:04:29Z",
            "sortOrder": "CREATED_DESC"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/400384164087",
            "title": "Intellectual Well-Being",
            "handle": "intellectual-well-being",
            "updatedAt": "2025-03-06T21:03:12Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/400384393463",
            "title": "Social Well-Being",
            "handle": "social-well-being",
            "updatedAt": "2025-03-04T16:04:30Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/400384819447",
            "title": "Financial Well-Being",
            "handle": "financial-well-being",
            "updatedAt": "2025-03-04T16:04:30Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/400384884983",
            "title": "Environmental Well-Being",
            "handle": "environmental-well-being",
            "updatedAt": "2025-03-04T16:04:30Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/474119471351",
            "title": "Gym Bags",
            "handle": "gym-bags",
            "updatedAt": "2025-03-04T16:04:30Z",
            "sortOrder": "ALPHA_ASC"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/477466362103",
            "title": "New Arrivals",
            "handle": "new-arrivals",
            "updatedAt": "2025-03-07T20:37:14Z",
            "sortOrder": "MANUAL"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/478084956407",
            "title": "Our Recommendations",
            "handle": "our-recommendations",
            "updatedAt": "2025-03-04T16:04:30Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/478089183479",
            "title": "Sale",
            "handle": "sale",
            "updatedAt": "2025-03-04T16:04:30Z",
            "sortOrder": "PRICE_ASC"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/478089576695",
            "title": "Exclusive",
            "handle": "exclusive",
            "updatedAt": "2025-03-04T16:04:30Z",
            "sortOrder": "PRICE_DESC"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/478089609463",
            "title": "Style",
            "handle": "style",
            "updatedAt": "2025-03-08T16:34:24Z",
            "sortOrder": "BEST_SELLING"
          }
        },
        {
          "node": {
            "id": "gid://shopify/Collection/478089740535",
            "title": "Favorites",
            "handle": "best-sellers",
            "updatedAt": "2025-03-06T16:51:33Z",
            "sortOrder": "BEST_SELLING"
          }
        }
      ]
    }
  },
  "extensions": {
    "cost": {
      "requestedQueryCost": 13,
      "actualQueryCost": 11,
      "throttleStatus": {
        "maximumAvailable": 4000,
        "currentlyAvailable": 3989,
        "restoreRate": 200
      }
    }
  }
}
=end