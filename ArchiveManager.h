#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ArchiveVirtualPathSeparator;

@interface ArchiveManager : NSObject

/// Détermine si le fichier à ce chemin est une archive prise en charge
+ (BOOL)isSupportedArchive:(NSString *)path;

/// Renvoie le chemin virtuel (creevey://...) à partir du chemin de l'archive et du nom de fichier interne
+ (NSURL *)virtualURLForArchive:(NSString *)archivePath internalPath:(NSString *)internalPath;

/// Décompose une URL virtuelle. Renvoie l'archive réelle et le chemin interne, ou nil si ce n'est pas une archive.
+ (BOOL)parseVirtualURL:(NSURL *)url archivePath:(NSString * __autoreleasing *)outArchivePath internalPath:(NSString * __autoreleasing *)outInternalPath;

/// Liste le contenu d'une archive. Les résultats sont des NSURL (virtuels).
/// Exclut les dossiers et ignore les archives "solides".
+ (NSArray<NSURL *> *)scanArchive:(NSString *)archivePath;

/// Extrait les données en mémoire pour un chemin virtuel donné.
+ (NSData *)dataForVirtualURL:(NSURL *)url;

/// Crée un CGImageSourceRef depuis un chemin virtuel ou réel. (L'appelant doit faire CFRelease)
+ (CGImageSourceRef)imageSourceForPath:(NSString *)path CF_RETURNS_RETAINED;

/// Retourne la taille non compressée d'un fichier dans l'archive.
+ (unsigned long long)fileSizeForVirtualPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
