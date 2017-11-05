# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  seller_id    :integer
#  name         :string
#  price        :decimal(, )
#  description  :text
#  condition    :string
#  status       :string
#  category     :string
#  manufacturer :string
#  publisher    :string
#  publish_date :date
#  author       :string
#  illustrator  :string
#  isbn_10      :string
#  isbn_13      :string
#  dimensions   :string
#  weight       :decimal(, )
#  keywords     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  postage      :string
#

class Product < ApplicationRecord
  include AlgoliaSearch

  algoliasearch do
    # All Attributes Used by Algolia
    attribute :name, :keywords, :description, :seller_name, :manufacturer, :publisher, :author, :illustrator, :view_count, :latitude, :longitude, :status, :category

    # Search Index
    searchableAttributes ['name', 'keywords', 'unordered(description)', 'seller_name', 'unordered(manufacturer)', 'unordered(publisher)', 'unordered(author)', 'unordered(illustrator)']

    # Rank by Product View Count
    customRanking ['desc(view_count)']

    # Location Search by Radius
    geoloc :latitude, :longitude

    # Filters
    # attributesForFaceting ['status', 'category']
    # attributesForFaceting [:company]
    attributesForFaceting [:status, :manufacturer, :publisher, :category, :seller_name]
    # tags [:keywords]
  end

  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos
  belongs_to :seller, class_name: 'User'
  has_many :product_views, dependent: :destroy
  has_many :shopping_carts, dependent: :destroy
  has_many :watchlists, dependent: :destroy

  enum category_types: ['Comic Books & Graphic Novels', 'Toys & Collectables', 'Costumes', 'Clothing & Apparel']
  enum condition_types: ['Brand New', 'Mint', 'Good', 'Fair', 'Poor']
  enum status_types: ['Available', 'Checked Out', 'Sold']
  enum postage_types: ['None/Pickup Only', 'By Weight']

  validates :seller_id, uniqueness: { scope: :name, message: 'Product name already exists' }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true
  validates :condition, presence: true
  validates :status, presence: true
  validates :category, presence: true
  validates :name, presence: true
  validates :postage, presence: true

  # Full name of the Seller
  def seller_name
    seller.profile.full_name
  end

  # Location of the Seller
  def seller_location
    seller.profile.billing_address.full_address
  end

  # Coordinates of the Seller's location
  # def seller_coordinates
  #   Geocoder.coordinates(seller_location) if seller_location.present?
  # end

  # Seller's latitude
  def latitude
    seller.profile.billing_address.latitude
  end

  # Seller's longitude
  def longitude
    seller.profile.shipping_address.longitude
  end

  # Distance between the seller and buyer
  def distance_from_seller(buyer)
    seller_coordinates = "#{latitude}, #{longitude}"
    buyer_coordinates = "#{buyer.profile.billing_address.latitude}, #{buyer.profile.billing_address.longitude}"
    Geocoder::Calculations.distance_between(seller_coordinates, buyer_coordinates, :units => :km)
  end

  # When the buyer, views the Product
  def toggle_viewed_by(buyer)
    unless ProductView.find_by(product_id: self.id, buyer: buyer).present?
      ProductView.create(product_id: self.id, buyer: buyer)
    end
  end

  # Count the Product Views
  def view_count
    product_views.count
  end

  # Check if already added in Shopping Cart
  def added_to_cart?(buyer)
    ShoppingCart.find_by(product_id: self.id, buyer: buyer).present?
  end

  # Check if already added in Watchlist
  def added_to_watchlist?(buyer)
    Watchlist.find_by(product_id: self.id, buyer: buyer).present?
  end

end
