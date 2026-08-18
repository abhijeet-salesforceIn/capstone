public with sharing class FoodOptionsServiceNew {
    
    // Inner class representing a food name-image pair
    public class FoodItem {
        public String title;
        public String imageUrl;
        public String mimeType;
        public String subTitle;
        

        public FoodItem(String title, String imageUrl, String mimeType, String subTitle) {
            this.title = title;
            this.imageUrl = imageUrl;
            this.mimeType = mimeType;
            this.subTitle = subTitle;
        }
    }

    // Wrapper class to hold the list of food items
    public class FoodOptionWrapper {
        @InvocableVariable(label='Food Options' required=true)
        public List<FoodItem> foodItems;

        public FoodOptionWrapper() {
            this.foodItems = new List<FoodItem>();
        }
    }

    // Class for input parameter
    public class FoodOptionInput {
        @InvocableVariable(label='Cuisine Name' required=true)
        public String cuisineName;
    }

    // Invocable method returning a single FoodOptionWrapper object
    @InvocableMethod(label='Get Food Options wrapper by Cuisine' description='Returns a list of food options based on the cuisine name')
    public static List<FoodOptionWrapper> getFoodOptionsByCuisine(List<FoodOptionInput> cuisineNames) {
        System.debug('cuisineNames: ' + cuisineNames);
        
        // Get the first cuisine name from the input list
        String cuisine = cuisineNames[0].cuisineName.toLowerCase();
        System.debug('Processing cuisine: ' + cuisine);
        
        FoodOptionWrapper selectedFoodWrapper = new FoodOptionWrapper();
        if(cuisine.contains('italian')) {
            selectedFoodWrapper.foodItems.add(new FoodItem('Pizza', 'https://as1.ftcdn.net/v2/jpg/06/36/30/26/1000_F_636302609_Tb1JtDTQ4zawO0ub6L2fHzlrW586f9tr.jpg','image/jpeg','Best Tiramisu in Planet Earth'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Pasta', 'https://as1.ftcdn.net/v2/jpg/03/02/21/92/1000_F_302219263_NDP2Cfs8uacAeOAcaV7cppbbd2LrDoEQ.jpg','image/jpeg','Best Pasta in Universe'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Tiramisu', 'https://as2.ftcdn.net/v2/jpg/03/46/17/09/1000_F_346170975_ezUUoZgYQ7fbAPzEWYWQ44G9lf13Gcel.jpg','image/jpeg',null));
        }
        else if(cuisine.contains('mexican')) {
            selectedFoodWrapper.foodItems.add(new FoodItem('Tacos', 'https://as1.ftcdn.net/v2/jpg/06/36/30/26/1000_F_636302609_Tb1JtDTQ4zawO0ub6L2fHzlrW586f9tr.jpg','image/jpeg','xYZXYZ'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Pasta', 'https://as1.ftcdn.net/v2/jpg/03/02/21/92/1000_F_302219263_NDP2Cfs8uacAeOAcaV7cppbbd2LrDoEQ.jpg','image/jpeg','ZZZ '));
            selectedFoodWrapper.foodItems.add(new FoodItem('Nachos', 'https://as2.ftcdn.net/v2/jpg/03/62/43/65/1000_F_362436538_feLwKqaZeyeqF3SYXCNYI8mapQEvrxrN.jpg','image/jpeg','WE ARE THE CHAMPIONS'));
        }
        else if (cuisine.contains('french')) {
            selectedFoodWrapper.foodItems.add(new FoodItem('Croissant', 'https://as1.ftcdn.net/v2/jpg/03/12/65/98/1000_F_312659844_e2wF8NfYq1BhIRpq27phQMHszygy5Ewo.jpg', 'image/jpeg',null));
            selectedFoodWrapper.foodItems.add(new FoodItem('Ratatouille', 'https://as2.ftcdn.net/v2/jpg/02/27/19/35/1000_F_227193527_7SuF0xXYrs8Aorj0KquYClX9W8Ixx5g8.jpg', 'image/jpeg',null));
            selectedFoodWrapper.foodItems.add(new FoodItem('Crème Brûlée', 'https://as1.ftcdn.net/v2/jpg/03/21/32/98/1000_F_321329812_bAc8cXo1qBy0ZsxuJaz9ZYF0sYivH8HX.jpg', 'image/jpeg',null));
        } else if (cuisine.contains('japanese')) {
            selectedFoodWrapper.foodItems.add(new FoodItem('Sushi', 'https://as1.ftcdn.net/v2/jpg/05/72/64/86/1000_F_572648657_zcz3H5rgyf6Ma6kUgB60EprLdY7oZz4X.jpg', 'image/jpeg','this is subtitle'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Ramen', 'https://as1.ftcdn.net/v2/jpg/04/26/93/07/1000_F_426930743_6Iro5jxVztDYUjBqTeGGL1FQoUQJRsM5.jpg', 'image/jpeg','this is subtitle'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Tempura', 'https://as1.ftcdn.net/v2/jpg/02/21/98/32/1000_F_221983264_zvhLlOkdKq5vdgItdfu9uJmYTrm7rZfM.jpg', 'image/jpeg','this is subtitle'));
        } else if (cuisine.contains('chinese')) {
            selectedFoodWrapper.foodItems.add(new FoodItem('Dumplings', 'https://as1.ftcdn.net/v2/jpg/05/65/68/19/1000_F_565681916_LhnibkBWqvxT40kXQlHfQblXbK1FEu4B.jpg', 'image/jpeg','this is subtitle'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Peking Duck', 'https://as2.ftcdn.net/v2/jpg/02/32/99/67/1000_F_232996720_rFW6OJvXhW0MxQ9jVq63fGBPaAPQfLSn.jpg', 'image/jpeg','this is subtitle'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Spring Rolls', 'https://as1.ftcdn.net/v2/jpg/02/20/74/68/1000_F_220746881_oS8lmWEXbw9de3YH5BoBwck9mhR7L2z3.jpg', 'image/jpeg','this is subtitle'));
        } else if (cuisine.contains('american')) {
            selectedFoodWrapper.foodItems.add(new FoodItem('Burger', 'https://as1.ftcdn.net/v2/jpg/04/81/94/39/1000_F_481943923_FJ40i5d0Y5pZfsl2T9uBQQFr1l3U4wEM.jpg', 'image/jpeg','this is subtitle'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Hot Dog', 'https://as2.ftcdn.net/v2/jpg/02/50/17/63/1000_F_250176307_bSi7WlkdDkjJ39TLOqirXsoNqTyheNJc.jpg', 'image/jpeg','this is subtitle'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Apple Pie', 'https://as1.ftcdn.net/v2/jpg/03/28/52/96/1000_F_328529613_4jT7o6Tn5Q5lItZq8oUqYwxTToAAzOKq.jpg', 'image/jpeg','this is subtitle'));
        } else if (cuisine.contains('indian')) {
            selectedFoodWrapper.foodItems.add(new FoodItem('Biryani', 'https://as1.ftcdn.net/v2/jpg/04/11/63/75/1000_F_411637525_8Yw6yPFeBGZjF6OGgDxJhHYKoRMfqjAe.jpg', 'image/jpeg','this is subtitle'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Samosa', 'https://as2.ftcdn.net/v2/jpg/03/46/93/34/1000_F_346933403_vU8WOfFn0UsqZ56FevFzHlRWlYycI9kV.jpg', 'image/jpeg','this is subtitle'));
            selectedFoodWrapper.foodItems.add(new FoodItem('Gulab Jamun', 'https://as1.ftcdn.net/v2/jpg/02/29/47/34/1000_F_229473452_XcN8zEUcQuMwHvDfwrrOs1PqB7XT3w6Y.jpg', 'image/jpeg','this is subtitle'));
        } else {
            selectedFoodWrapper.foodItems.add(new FoodItem('Unknown Food', 'https://example.com/images/default.jpg', 'image/jpeg','unkown subtitle'));
        }
        System.debug('Returning : ' + selectedFoodWrapper);
        return new List<FoodOptionWrapper>{ selectedFoodWrapper }; // Returning a single object inside a list
    }
}