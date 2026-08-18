public class GetFoodDetailsInvocable {
    
    @InvocableMethod(label='Get Food Details' description='Returns linkURL, linkTitle, Image linkURL, and MIME Type for a given food name')
    public static List<FoodDetailResponse> getFoodDetails(List<FoodDetailRequest> requests) {
        List<FoodDetailResponse> responses = new List<FoodDetailResponse>();

        for (FoodDetailRequest request : requests) {
            FoodDetailResponse response = new FoodDetailResponse();
            FoodDetail foodDetail = new FoodDetail();
            String foodName = request.foodName.toLowerCase();

            // Populate food details dynamically from GetFoodOptionsInvocable selections
            if (foodName.contains('pizza')) {
                foodDetail.linkURL = 'https://www.foodnetwork.com/recipes/alton-brown/pizza-pizzas-recipe4-1951401';
                foodDetail.linkTitle = 'Delicious Pizza';
                foodDetail.linkImageURL = 'https://plus.unsplash.com/premium_photo-1673439304183-8840bd0dc1bf';
                foodDetail.linkImageMimeType = 'image/jpeg';
                
            } else if (foodName.contains('pasta')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/pasta';
                foodDetail.linkTitle = 'Tasty Pasta';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1606761568499-5ddd45e43b32';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('tiramisu')) {
                foodDetail.linkURL = 'https://tastesbetterfromscratch.com/easy-tiramisu/';
                foodDetail.linkTitle = 'Classic Tiramisu';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('tacos')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/tacos';
                foodDetail.linkTitle = 'Authentic Mexican Tacos';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1551504734-5ee1c4a127da';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('quesadilla')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/quesadilla';
                foodDetail.linkTitle = 'Cheesy Quesadilla';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1613952273499-5de42c1789c7';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('nachos')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/nachos';
                foodDetail.linkTitle = 'Loaded Nachos';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1606755962773-b35f5d518c46';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('croissant')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/croissant';
                foodDetail.linkTitle = 'Fresh Croissant';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1587049352907-23d8ff0ceac3';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('ratatouille')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/ratatouille';
                foodDetail.linkTitle = 'Traditional Ratatouille';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1633527076476-f847fc6d16a2';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('creme brulee')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/creme-brulee';
                foodDetail.linkTitle = 'French Crème Brûlée';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1609767400465-45e06f28a680';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('sushi')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/sushi';
                foodDetail.linkTitle = 'Japanese Sushi';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1589308078050-cf38fe054d63';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('ramen')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/ramen';
                foodDetail.linkTitle = 'Delicious Ramen';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1602334872613-3ab02f3c95a7';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('tempura')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/tempura';
                foodDetail.linkTitle = 'Crispy Tempura';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1571771439241-89b31f5092c7';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('dumplings')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/dumplings';
                foodDetail.linkTitle = 'Chinese Dumplings';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1617196036851-20ce58a15b1b';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('peking duck')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/peking-duck';
                foodDetail.linkTitle = 'Peking Duck';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1643989946129-73e3a872ad80';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('spring rolls')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/spring-rolls';
                foodDetail.linkTitle = 'Fresh Spring Rolls';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1604328698692-80d9b81baf4d';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('burger')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/burger';
                foodDetail.linkTitle = 'Classic Burger';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1551782450-a2132b4ba21d';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('hot dog')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/hot-dog';
                foodDetail.linkTitle = 'Grilled Hot Dog';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1621248313959-d6c0e480c54e';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else if (foodName.contains('apple pie')) {
                foodDetail.linkURL = 'https://www.foodwebsite.com/apple-pie';
                foodDetail.linkTitle = 'Homemade Apple Pie';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1606760225157-145fe46c0b7f';
                foodDetail.linkImageMimeType = 'image/jpeg';
            } else {
                foodDetail.linkURL = 'https://www.foodwebsite.com/food';
                foodDetail.linkTitle = 'Unknown Food';
                foodDetail.linkImageURL = 'https://images.unsplash.com/photo-1606851093480-b24197b5fd6a';
                foodDetail.linkImageMimeType = 'image/jpeg';
            }
            response.foodDetails.add(foodDetail);
            responses.add(response);
            return responses;
        }
        
        return responses;
    }

    // Request Wrapper Class
    public class FoodDetailRequest {
        @InvocableVariable(label='Food Name' description='The name of the food item' required=true)
        public String foodName;
    }
    
    public class FoodDetail { 
        public String linkURL;
        
        public String linkTitle;
        
        public String linkImageURL;
        
        public String linkImageMimeType ;
       
    }

    // Response Wrapper Class
    public class FoodDetailResponse {

        @InvocableVariable(label='Food Details' required=true)
        public List<FoodDetail> foodDetails;
        
         public FoodDetailResponse() {
            this.foodDetails = new List<FoodDetail>();
        }
    }
}