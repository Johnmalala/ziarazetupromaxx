import { supabase } from './supabase';

/**
 * Constructs the public URL for the first image in an array from Supabase Storage.
 * @param images An array of image paths from the storage bucket.
 * @param listingId The ID of the listing for debugging purposes.
 * @returns The full public URL for the first image, or a placeholder.
 */
export function getImageUrl(images: string[] | null | undefined, listingId?: string): string {
  const placeholder = 'https://img-wrapper.vercel.app/image?url=https://img-wrapper.vercel.app/image?url=https://img-wrapper.vercel.app/image?url=https://placehold.co/600x400.png?text=No+Image';

  if (!images || images.length === 0 || !images[0]) {
    return placeholder;
  }

  const firstImagePath = images[0];

  if (firstImagePath.startsWith('http')) {
    return firstImagePath;
  }
  
  const { data } = supabase
    .storage
    .from('listings_images')
    .getPublicUrl(firstImagePath);

  if (!data?.publicUrl) {
    console.error(`[Image Debug] Could not get public URL for listing ID "${listingId}" with image path "${firstImagePath}". Please check: 1. Is the bucket name 'listings_images'? 2. Does the file exist in the bucket? 3. Is the bucket public?`);
    return placeholder;
  }

  return data.publicUrl;
}
