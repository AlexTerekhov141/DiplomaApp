class PhotosRepositoryConstants {
  const PhotosRepositoryConstants._();

  static const String uploadedAssetIdsKey = 'uploaded_asset_ids_v1';
  static const String favoritePhotoIdsKey = 'favorite_photo_ids_v1';
  static const String trashedPhotoIdsKey = 'trashed_photo_ids_v1';
  static const String offlinePredictionsKey = 'offline_predictions_v1';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const String photosPath = '/api/photos/';
  static const String bulkUploadPath = '/api/photos/bulk-upload/';
  static const String bestPhotosPath = '/api/photos/best/';
  static const String categoriesPath = '/api/categories/';
  static const String tagsPath = '/api/tags/';
  static const String refreshPath = '/api/auth/refresh/';

  static const int uploadChunkSize = 20;
  static const int receiveTimeoutSeconds = 30;
}
