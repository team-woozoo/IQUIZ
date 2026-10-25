import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.bae.iquiz.dev"
            resValue(type = "string", name = "app_name", value = "[DEV]iquiz")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.bae.iquiz.prod"
            resValue(type = "string", name = "app_name", value = "iquiz")
        }
    }

    buildFeatures.resValues = true
}