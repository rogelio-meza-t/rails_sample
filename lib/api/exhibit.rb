module Api
  
  class Exhibit
    
    def prepare(tours)
    end
  
  end
  
  class ScheduledTourSearchModelExhibit < Exhibit
    
    def prepare(tours)
      # bea: change it to sort by priority
      tours.sort_by { |t| t.date}
    end
  end
  
  class ScheduledTourSearchJsonExhibit < Exhibit
    include DateTimeHelper
    include CurrencyHelper

    def prepare(tours)
      tours.collect { | tour |
        one_tour(tour)
      }.sort_by { | elt |
        elt[:date]
      }
    end
    
    def one_tour(tour)
      
      scheduled_tour = tour.tour_operator
      {
        id:             tour.id,
        date:           tour.date.strftime("%d/%m/%Y"),
        start_time:     tour.product_schedule.start_time.strftime("%k:%M"),
        min_capacity:   tour.product.min_capacity,
        max_capacity:   tour.product.max_capacity,
        room_available: tour.room_available,
        max:            [tour.product.max_capacity, tour.room_available].min,
        min:            tour.reserved_count >= tour.product.min_capacity ? 1 : (tour.product.min_capacity - tour.reserved_count)
        
      #product = tour.product
      #tour_operator = tour.tour_operator
      #{
      #  tour_operator: {
      #    name: tour_operator.name,
      #    address: tour_operator.address,
      #    country: tour_operator.country,
      #    time_zone: tour_operator.time_zone,
      #    phone: tour_operator.phone,
      #    email: tour_operator.email,
      #    contact_person: tour_operator.contact_person,
      #    logo_url: tour_operator.image.url(:original),
      #    translations: Hash[tour_operator.translations.collect{|t| 
      #      [t.locale, {
      #          description: t.description,
      #          terms_and_conditions: t.terms_and_conditions
      #        } 
      #      ]
      #    }]
      #  },

      #  scheduled_tour_id: tour.id,
      #  date: interchange_date_format(tour.date),
      #  prices: product.product_prices.collect{ |price| 
      #    {
      #      currency_code: price.currency_code,
      #      price: price.price
      #    }
      #  },
      #  location: product.location,
      #  languages: product.languages,
      #  image_urls: product.product_images.collect{ |i| i.image.url },
      #  min_capacity: product.min_capacity,
      #  max_capacity: product.max_capacity,
      #  room_available: tour.room_available,
      #  start_time: friendly_time_format(product.start_time),
      #  duration: product.duration,
      #  translations: Hash[product.translations.collect{ |t| 
      #    [t.locale, {
      #        name: t.name,
      #        description: t.description,
      #        difficulty: t.difficulty, 
      #        meeting_point: t.meeting_point, 
      #        what_to_bring: t.what_to_bring, 
      #        whats_included: t.whats_included
      #      } 
      #    ]
      #  }]
      }
    end
  end
  
  
  class ProductSearchModelExhibit < Exhibit
    
    def prepare(tours)
      tours.sort_by { |t| t.priority}
    end
  end
  
  class ProductSearchJsonExhibit < Exhibit
    include DateTimeHelper
    include CurrencyHelper

    def prepare(tours)
      
      # bea: change it to sort by priority
      tours.collect { | tour |
        one_tour(tour)
      }.sort_by { | elt |
        elt[:priority]
      }
    end
    
    def one_tour(tour)
      
      product = tour
      tour_operator = tour.tour_operator
      {
        tour_operator: {
          name: tour_operator.name,
          address: tour_operator.address,
          country: tour_operator.country,
          time_zone: tour_operator.time_zone,
          phone: tour_operator.phone,
          email: tour_operator.email,
          contact_person: tour_operator.contact_person,
          logo_url: tour_operator.image.url(:original),
          translations: Hash[tour_operator.translations.collect{|t| 
            [t.locale, {
                description: t.description,
                terms_and_conditions: t.terms_and_conditions
              } 
            ]
          }]
        },

        #scheduled_tour_id: tour.id,
        date: interchange_date_format(tour.date),
        prices: product.product_prices.collect{ |price| 
          {
            currency_code: price.currency_code,
            price: price.price
          }
        },
        location: product.location,
        languages: product.languages,
        image_urls: product.product_images.collect{ |i| i.image.url },
        min_capacity: product.min_capacity,
        max_capacity: product.max_capacity,
        #room_available: tour.room_available,
        start_time: friendly_time_format(product.start_time),
        duration: product.duration,
        translations: Hash[product.translations.collect{ |t| 
          [t.locale, {
              name: t.name,
              description: t.description,
              difficulty: t.difficulty, 
              meeting_point: t.meeting_point, 
              what_to_bring: t.what_to_bring, 
              whats_included: t.whats_included
            } 
          ]
        }]
      }
    end
  end
  
  
end