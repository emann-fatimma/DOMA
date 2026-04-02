import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/review_provider.dart';

class RateReviewScreen extends StatefulWidget {
  final String productId;
  final String productTitle;

  const RateReviewScreen({super.key, required this.productId, required this.productTitle});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  double _rating = 5.0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Rate Product"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Reviewing ${widget.productTitle}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (val) => setState(() => _rating = val),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: InputDecoration(hintText: "What did you think of the quality?", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: provider.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  child: provider.isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit Review", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final res = await context.read<ReviewProvider>().submitReview(
      productId: widget.productId,
      rating: _rating,
      description: _descController.text,
    );

    if (res['success']) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
    }
  }
}