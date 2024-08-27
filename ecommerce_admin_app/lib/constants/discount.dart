// function to calculate the discount of old and new price
String discountPercent(int oldPrice, int currentPrice){
  if(oldPrice==0){
    return "0";
  }
  else{
    double discount= ((oldPrice-currentPrice)/oldPrice)*100;
    return discount.toStringAsFixed(0);
  }
}