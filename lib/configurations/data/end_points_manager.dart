class EndPointsStrings {
  static const baseUrl = "https://hrajyemen-001-site1.site4future.com/";
  static const emptyImageUrl = "https://media.istockphoto.com/id/2151669184/vector/vector-flat-illustration-in-grayscale-avatar-user-profile-person-icon-gender-neutral.jpg?s=1024x1024&w=is&k=20&c=KUoqqjDVM0CK523SpBQJCY3gRI4tuRSuejDphVaDUIQ=";
  static const emptyProductImageUrl = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj2GqhUbpEqRxJvzyk3TvXjZ0drENlUZUtyUEf0SxgT9s6QJfEt2X6WHORiJBreix1VMbi8Qi1Pgqel1G3nWElQywahVfUI8U6kfjMfELukWOsWbJorp0ODdBL2oJXOLft-XRu02-r_WIw/s1600/placeholder-image.jpg";

  static const registerUserEndPoint = "";
  static const loginUserEndPoint = "api/Account/Login";
  static const getCitiesEndPoint = "api/Cities";
  static const getUserProfileEndPoint = "api/Admin/Get";
  static const postRegisterClientEndPoint = "api/Admin/RegisterClient";
  static const putClientEndPoint = "api/Admin/PutClient/";
  static const getRegionsByCityEndPoint = "api/Regions/by-city";
  static const getRegionsEndPoint = "api/Regions/";
  static const getCategoriesEndPoint = "api/Categories";
  static const getSubCategoriesByCategoryEndPoint = "api/SubCategories/by-category";
  static const getSubCategoriesEndPoint = "api/SubCategories/";
  static const getProductsEndPoint = "api/Products";
  static const createProductsEndPoint = "api/Products";
  static const wityEndPoint = "";

  static String get postCommentEndPoint => 'api/ProductComments';

  static String get resetPasswordEndPoint => 'api/Admin/ForgetPassword';

  static String get banksEndPoint => 'api/Banks';
}
